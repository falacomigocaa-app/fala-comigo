const baseUsers = [
  { id: 'user-admin-alpha', externalSubject: 'synthetic:admin-alpha', status: 'active' },
  { id: 'user-professional-alpha', externalSubject: 'synthetic:professional-alpha', status: 'active' },
  { id: 'user-admin-beta', externalSubject: 'synthetic:admin-beta', status: 'active' },
  { id: 'user-outsider', externalSubject: 'synthetic:outsider', status: 'active' },
  { id: 'user-invitee-alpha', externalSubject: 'synthetic:invitee-alpha', status: 'active' }
];

const baseOrganizations = [
  { id: 'org-demo-alpha', name: 'Clínica Aurora Demo', status: 'active' },
  { id: 'org-demo-beta', name: 'Escola Horizonte Demo', status: 'active' }
];

const roleScopes = {
  owner: ['organization.read', 'membership.read', 'access.invite', 'access.read', 'access.revoke', 'benefit.read', 'audit.read'],
  org_admin: ['organization.read', 'membership.read', 'access.invite', 'access.read', 'benefit.read'],
  professional: ['organization.read', 'access.read'],
  outsider: []
};

const baseMemberships = [
  { id: 'membership-admin-alpha', userId: 'user-admin-alpha', organizationId: 'org-demo-alpha', role: 'owner', status: 'active', validUntil: '2099-01-01T00:00:00.000Z' },
  { id: 'membership-professional-alpha', userId: 'user-professional-alpha', organizationId: 'org-demo-alpha', role: 'professional', status: 'active', validUntil: '2099-01-01T00:00:00.000Z' },
  { id: 'membership-admin-beta', userId: 'user-admin-beta', organizationId: 'org-demo-beta', role: 'owner', status: 'active', validUntil: '2099-01-01T00:00:00.000Z' }
];

const baseInvitations = [
  { id: 'invite-alpha-pending', organizationId: 'org-demo-alpha', inviteeUserId: 'user-invitee-alpha', role: 'professional', status: 'pending', expiresAt: '2099-01-01T00:00:00.000Z' },
  { id: 'invite-alpha-expired', organizationId: 'org-demo-alpha', inviteeUserId: 'user-invitee-alpha', role: 'professional', status: 'pending', expiresAt: '2020-01-01T00:00:00.000Z' }
];

const baseBenefits = [
  { id: 'benefit-demo-alpha', organizationId: 'org-demo-alpha', status: 'active', validUntil: '2099-01-01T00:00:00.000Z' }
];

export function createStore() {
  return {
    users: structuredClone(baseUsers),
    organizations: structuredClone(baseOrganizations),
    memberships: structuredClone(baseMemberships),
    invitations: structuredClone(baseInvitations),
    benefits: structuredClone(baseBenefits),
    grants: [],
    auditEvents: [],
    idempotency: new Map()
  };
}

export { roleScopes };
