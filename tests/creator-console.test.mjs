import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const root = join(dirname(fileURLToPath(import.meta.url)), "..");
const preview = readFileSync(join(root, "site/console-preview.html"), "utf8");
const publicSite = readFileSync(join(root, "site/index.html"), "utf8");

test("creator preview exposes only the two approved global counts", () => {
  assert.equal((preview.match(/<article class="metric">/g) ?? []).length, 2);
  assert.match(preview, /Total de lotes/);
  assert.match(preview, /Total de códigos emitidos/);
  assert.doesNotMatch(preview, /<div class="metric-label">(?:Licenças disponíveis|Total de resgates)/i);
});

test("creator preview does not expose a per-batch list or identifiers", () => {
  assert.doesNotMatch(preview, /<table\b|class="batch-id"|DEMO-[A-Z]\d+/i);
  assert.match(
    preview,
    /Não há referência, modalidade, versão, data, estado ou total de resgates por lote/i,
  );
});

test("public plans show Essential as free and paid plans as consultation-only", () => {
  const displayedPrices = [...publicSite.matchAll(/<span class="plan-price">([^<]+)<\/span>/g)]
    .map((match) => match[1].trim());

  assert.deepEqual(displayedPrices, ["Gratuito", "Sob consulta", "Sob consulta"]);
});

test("public site does not link to the legacy Manus creator portal", () => {
  assert.doesNotMatch(publicSite, /https:\/\/falacomigo-kyrh225w\.manus\.space\/creator/i);
});

test("creator preview remains explicitly a non-functional demo", () => {
  assert.match(preview, /Protótipo visual — não é um painel funcional/);
  assert.match(preview, /não há login, conexão com Supabase, cadastro de usuários nem pagamentos/i);
  assert.match(preview, /Nenhuma licença foi criada ou salva/);
  assert.match(preview, /O workflow do site inclui este arquivo no artefato do Pages/);
  assert.doesNotMatch(preview, /Esta prévia não é uma tela publicada/i);
});
