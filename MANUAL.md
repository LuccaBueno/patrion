# Manual do kit — como usar com o Claude Code

Este kit substitui o "prompt mestre" único por arquivos que o Claude Code lê sozinho em toda sessão. Você só manda prompts curtos, um por fase.

## 1. O que tem no kit

| Arquivo | Para que serve | Quem edita |
|---|---|---|
| `CLAUDE.md` | Regras permanentes: stack, regras invioláveis, forma de trabalhar e comandos. O Claude Code lê automaticamente. | Você (raramente) |
| `docs/SPEC.md` | Especificação completa do app e das fases (§21). | Você, quando mudar de ideia |
| `docs/CASOS_DE_TESTE.md` | Cálculos de referência conferidos. Os testes têm de bater com eles. | Você e o Claude (com sua aprovação) |
| `docs/DECISIONS.md` | Decisões técnicas e os motivos. | Claude |
| `docs/PROGRESS.md` | Onde o projeto parou. É a "memória" entre sessões. | Claude |
| `MANUAL.md` | Este arquivo. | — |
| `assets/branding/` | Esboço da logo do Patrion. | Você |

O arquivo de save entre computadores está especificado em `SPEC.md` §10. Ele é construído na Fase 5, mas o banco já nasce preparado para ele desde a Fase 2.

## 2. Preparação (uma vez, antes de começar)

No PC principal (Windows 10 ou 11):

1. **Git:** instale e configure seu nome e e-mail.
2. **Flutter SDK (canal stable):** coloque no PATH.
3. **Visual Studio 2022 (Community):** instale com a carga de trabalho **"Desenvolvimento para desktop com C++"**. O Flutter precisa dela para compilar no Windows; o VS Code não substitui.
4. **Inno Setup 6:** necessário para gerar o instalador `.exe`.
5. **Claude Code:** instale pela documentação oficial (docs.claude.com) e faça login.
6. **Conta no GitHub.** Para o Claude publicar por você, instale também o GitHub CLI (`gh`) e rode `gh auth login`.

Confira tudo no PowerShell:

```powershell
git --version
flutter doctor
```

O `flutter doctor` precisa mostrar ✓ em "Windows" e em "Visual Studio". Android e Chrome podem ficar com aviso.

## 3. Montar a pasta do projeto

1. Crie uma pasta sem espaços nem acentos, por exemplo `C:\dev\patrion`.
2. Copie para dentro dela `CLAUDE.md`, a pasta `docs\` e `MANUAL.md`.
3. O nome (Patrion) já está aplicado em todos os arquivos. A logo está em `assets\branding\`.
4. Abra o PowerShell nessa pasta e rode `claude`.

Não use pasta sincronizada pelo OneDrive para o código: ela atrapalha builds e o Git.

## 4. Regras de ouro para trabalhar com o Claude Code

- **Uma fase por sessão.** Ao terminar, rode `/clear` (ou abra uma sessão nova) antes da próxima. O `PROGRESS.md` garante a continuidade.
- **Revise antes de aprovar.** O Claude pede permissão para comandos e edições. No começo, leia o que ele vai fazer.
- **Teste você mesmo.** Ao fim de cada fase, abra o app (`flutter run -d windows`) e faça o checklist manual que ele indicar.
- **Commits locais são livres; publicar é com você.** `push`, tags e Releases só acontecem quando você pedir.
- **Mudou de ideia?** Edite a `SPEC.md` primeiro e depois peça a mudança. A especificação é a fonte da verdade.
- **Contexto grande:** se ele avisar, ou se começar a esquecer regras, peça `atualize o PROGRESS.md` e abra uma sessão nova.

## 5. Prompts para copiar e colar

### Fase 1 — ambiente e decisões

```
Leia CLAUDE.md e todos os arquivos de docs/. Vamos executar a Fase 1 da SPEC (§21).

1. Verifique o ambiente (flutter doctor, git, Inno Setup) e me diga o que falta.
2. Pesquise a documentação ATUAL das fontes de dados de SPEC §4 e crie
   docs/FONTES_DE_DADOS.md com a matriz pedida. Dê atenção especial a histórico
   de ativos BR com proventos e eventos corporativos.
3. Proponha as dependências (com versões) e preencha DECISIONS.md.
4. Proponha o modelo de dados em docs/BANCO.md, com campos de sincronização,
   tabelas hipotéticas separadas e separação entre configurações do dispositivo
   e configurações compartilhadas.
5. Crie o projeto Flutter, o .gitignore e o repositório Git local, e faça o
   primeiro `flutter build windows`.

Antes de criar o projeto (passo 5), PARE e me apresente um resumo das decisões
dos passos 2 a 4 para eu aprovar.
```

### Fases 2 em diante (modelo)

Troque o número da fase:

```
Leia CLAUDE.md e docs/PROGRESS.md. Execute a Fase N da SPEC (§21) até o
critério de pronto. Ao terminar, rode format, analyze, test e build, faça
o relatório da fase e atualize PROGRESS.md e CHANGELOG.
```

Acréscimos úteis por fase:

- **Fase 4:** "Os testes devem começar pelos casos de docs/CASOS_DE_TESTE.md §1 a §7."
- **Fase 5:** "Implemente os testes S1 a S10 de CASOS_DE_TESTE.md §9 antes da tela de importação."
- **Fase 7:** "Prepare o workflow de release, mas não crie tag nem faça push sem eu pedir."

### Retomar uma fase interrompida

```
Leia CLAUDE.md e docs/PROGRESS.md. Continue a fase em andamento de onde parou.
```

### Corrigir um bug

```
Bug: [o que fiz] → [o que esperava] → [o que aconteceu]. [cole o erro, se houver]
Reproduza com um teste que falhe, corrija e confirme que o teste passa.
```

### Publicar uma versão

```
Quero publicar a versão X.Y.Z. Confira se analyze, test e build estão ok,
atualize o CHANGELOG, crie a tag, faça push e acompanhe o workflow até gerar a
Release em rascunho. Me mostre o link para eu revisar e publicar.
```

### Pedir uma funcionalidade nova

```
Quero [funcionalidade]. Primeiro atualize a SPEC.md com a proposta e me mostre.
Depois que eu aprovar, implemente.
```

## 6. Usando o arquivo de save entre os dois PCs

Disponível a partir da Fase 5.

- **Exportar (PC A):** clique em *Sincronização → Salvar arquivo de save*. O app gera `Patrion_PC-A_2026-11-03_1830.invsave`. Leve o arquivo como quiser: pendrive, rede local ou e-mail.
- **Importar (PC B):** clique em *Sincronização → Importar save*. O app faz um backup automático, mostra a prévia (novos, alterados, excluídos e conflitos) e só aplica quando você confirmar.
- **Se mexeu nos dois PCs:**
  1. Importe no B e use "Importar e gerar novo save".
  2. Leve esse novo arquivo de volta ao A e importe.
  3. Pronto: os dois ficam iguais.
- **Se mexeu só no A:** basta exportar no A e importar no B.

Avisos:

- Importar o mesmo arquivo duas vezes não duplica nada.
- Um arquivo antigo não desfaz alterações mais novas.
- Backup e save são coisas diferentes. O **backup** restaura este PC inteiro (substitui tudo). O **save** mescla dados entre PCs.
- Até a criptografia do save existir (v1.x), trate o arquivo como um documento sensível: ele contém sua carteira.

## 7. Roteiro de versões

| Versão | Fases | Resultado |
|---|---|---|
| v1.0 | 1 a 7 | App instalável: carteira real, cálculos testados, cotações, backup e save entre PCs |
| v1.x | 8 a 11 | Análises por classe, benchmarks, risco, carteiras hipotéticas, backtest, projeções e simuladores |
| v2 | 12 a 15 | Fundamentalista, relatórios, alertas, Monte Carlo e atualização automática |

Conte com várias sessões por fase. A Fase 1 pode precisar de idas e vindas na escolha das fontes de dados. Isso é esperado: é a decisão que mais impacta o backtest.

## 8. Problemas comuns

- **`flutter build windows` falha por falta de compilador:** falta a carga de trabalho C++ do Visual Studio.
- **O Claude quer pular de fase ou fazer tudo de uma vez:** responda "Pare. Só a Fase N, conforme CLAUDE.md."
- **O Claude disse que passou, mas você desconfia:** peça "rode `flutter test` agora e me mostre a saída".
- **Aviso do SmartScreen ao instalar:** é normal num instalador sem assinatura. Clique em "Mais informações" e depois em "Executar assim mesmo".
- **A fonte de dados gratuita não serve:** o Claude deve parar e propor alternativas (regra do CLAUDE.md). Decida você.
