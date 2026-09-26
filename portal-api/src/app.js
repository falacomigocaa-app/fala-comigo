import { AuthorizationError, audit, authenticate, requireScope, stableError } from './authorization.js';
import { createStore } from './store.js';

const jsonHeaders = { 'content-type': 'application/json; charset=utf-8' };

function response(status, body) {
  return { status, body };
}

function parsePath(url) {
  return new URL(url, 'http://localhost').pathname.split('/').filter(Boolean);
}

function sendAudit(store, context, action, result, error = null) {
  audit(store, {
    userId: context.user?.id ?? null,
    organizationId: context.organizationId,
    action,
    result,
    code: error?.code ?? null,
    requestId: context.requestId,
    now: context.now
  });
}

function idempotent(store, requestId, handler) {
  if (!requestId) return handler();
  if (store.idempotency.has(requestId)) return store.idempotency.get(requestId);
  const result = handler();
  store.idempotency.set(requestId, result);
  return result;
}

export function createApp({ store = createStore(), now = () => new Date('2026-09-25T12:00:00.000Z') } = {}) {
  async function handle({ method, url, headers = {}, body = null }) {
    const path = parsePath(url);
    const userId = headers['x-synthetic-user-id'];
    const requestId = headers['x-request-id'] ?? null;
    const clock = now();
    const context = { user: null, organizationId: null, requestId, now: clock };

    try {
      if (method === 'GET' && path[0] === 'v1' && path[1] === 'me') {
        context.user = authenticate(store, userId);
        return response(200, { id: context.user.id, status: context.user.status });
      }

      context.user = authenticate(store, userId);
      if (path[0] !== 'v1') return response(404, { error: 'NOT_FOUND' });

      if (method === 'GET' && path[1] === 'organizations' && path[3] === undefined && path[2]) {
        context.organizationId = path[2];
        requireScope(store, context.user.id, context.organizationId, 'organization.read', clock);
        const organization = store.organizations.find((item) => item.id === context.organizationId);
        if (!organization) throw new AuthorizationError('RELATIONSHIP_REQUIRED');
        sendAudit(store, context, 'organization.read', 'allowed');
        return response(200, organization);
      }

      if (method === 'GET' && path[1] === 'organizations' && path[3] === 'memberships') {
        context.organizationId = path[2];
        requireScope(store, context.user.id, context.organizationId, 'membership.read', clock);
        const memberships = store.memberships.filter((item) => item.organizationId === context.organizationId);
        sendAudit(store, context, 'membership.read', 'allowed');
        return response(200, { memberships });
      }

      if (method === 'POST' && path[1] === 'organizations' && path[3] === 'invitations') {
        context.organizationId = path[2];
        requireScope(store, context.user.id, context.organizationId, 'access.invite', clock);
        const result = idempotent(store, requestId, () => {
          const invitation = {
            id: `invite-created-${store.invitations.length + 1}`,
            organizationId: context.organizationId,
            inviteeUserId: body?.inviteeUserId ?? 'user-invitee-alpha',
            role: body?.role ?? 'professional',
            status: 'pending',
            expiresAt: body?.expiresAt ?? '2099-01-01T00:00:00.000Z'
          };
          store.invitations.push(invitation);
          sendAudit(store, context, 'invitation.create', 'allowed');
          return response(201, invitation);
        });
        return result;
      }

      if (method === 'GET' && path[1] === 'invitations' && path[2]) {
        const invitation = store.invitations.find((item) => item.id === path[2]);
        if (!invitation || invitation.inviteeUserId !== context.user.id) throw new AuthorizationError('RELATIONSHIP_REQUIRED');
        sendAudit(store, context, 'invitation.read', 'allowed');
        return response(200, invitation);
      }

      if (method === 'POST' && path[1] === 'invitations' && path[2] && (path[3] === 'accept' || path[3] === 'decline')) {
        const invitation = store.invitations.find((item) => item.id === path[2]);
        if (!invitation || invitation.inviteeUserId !== context.user.id) throw new AuthorizationError('RELATIONSHIP_REQUIRED');
        if (invitation.status !== 'pending') throw new AuthorizationError('REVOKED');
        if (new Date(invitation.expiresAt) <= clock) throw new AuthorizationError('EXPIRED');
        if (path[3] === 'decline') {
          invitation.status = 'declined';
          sendAudit(store, context, 'invitation.decline', 'allowed');
          return response(200, invitation);
        }
        invitation.status = 'accepted';
        const membership = {
          id: `membership-${invitation.id}`,
          userId: context.user.id,
          organizationId: invitation.organizationId,
          role: invitation.role,
          status: 'active',
          validUntil: invitation.expiresAt
        };
        store.memberships.push(membership);
        sendAudit(store, context, 'invitation.accept', 'allowed');
        return response(200, { invitation, membership });
      }

      if (method === 'GET' && path[1] === 'organizations' && path[3] === 'benefits') {
        context.organizationId = path[2];
        requireScope(store, context.user.id, context.organizationId, 'benefit.read', clock);
        const benefits = store.benefits.filter((item) => item.organizationId === context.organizationId);
        sendAudit(store, context, 'benefit.read', 'allowed');
        return response(200, { benefits });
      }

      if (method === 'GET' && path[1] === 'organizations' && path[3] === 'audit-events') {
        context.organizationId = path[2];
        requireScope(store, context.user.id, context.organizationId, 'audit.read', clock);
        return response(200, { events: store.auditEvents.filter((item) => item.organizationId === context.organizationId) });
      }

      return response(404, { error: 'NOT_FOUND' });
    } catch (rawError) {
      const error = stableError(rawError);
      if (context.user) sendAudit(store, context, 'request.denied', 'denied', error);
      return response(error.status, { error: error.code });
    }
  }

  return { handle, store };
}

export { jsonHeaders };
