# Progresso

Atualizado pelo Claude ao final de cada fase ou sessão.

## Fase atual

**Fase 1 concluída** em 17/10/2026. Próxima: Fase 2 (Fundação).

## Concluído

### Fase 1 — Ambiente e decisões

**1. O que foi implementado**

- Ambiente verificado: Flutter 3.47.7 / Dart 3.13.5, Visual Studio Build Tools 2022 (C++ e Windows SDK 10.0.26100), Git 2.55, GitHub CLI autenticado, Inno Setup 6 (instalação por usuário em `%LOCALAPPDATA%\Programs\Inno Setup 6\ISCC.exe`, fora do PATH).
- Pesquisa das fontes de dados com testes reais (`docs/FONTES_DE_DADOS.md`).
- Decisões D-01 a D-12 aprovadas pelo usuário, com ajustes em D-03, D-05, D-07 e D-08 (`docs/DECISIONS.md`).
- Modelo de dados aprovado (`docs/BANCO.md`).
- Regra 6 do `CLAUDE.md` atualizada (exceção de `double` só para gráficos em `presentation/`).
- Projeto Flutter só para Windows (org `io.github.luccabueno`), app vazio com nome e subtítulo, título da janela e recursos do executável como "Patrion".
- `.gitignore` com bancos, saves, backups, segredos e cache; repositório Git local na branch `main`.
- README e CHANGELOG.
- Proposta de símbolo vetorial (`assets/branding/patrion-simbolo.svg`).

**2. Arquivos criados ou alterados**

- Docs: `docs/FONTES_DE_DADOS.md`, `docs/BANCO.md` (novos); `docs/DECISIONS.md`, `docs/PROGRESS.md`, `CLAUDE.md` (alterados).
- Projeto: `pubspec.yaml`, `analysis_options.yaml` (lints mais rígidos), `lib/main.dart`, `test/widget_test.dart`, `windows/` (gerado; `main.cpp` e `Runner.rc` ajustados), `.gitignore`, `README.md`, `CHANGELOG.md`.

**3. Testes executados (17/10/2026)**

- `dart format .`: 2 arquivos, 0 alterados.
- `flutter analyze`: "No issues found!".
- `flutter test`: 1 teste, todos passaram.
- `flutter build windows --release`: compilou `build\windows\x64\runner\Release\patrion.exe`.
- Execução do `.exe`: a janela "Patrion" abriu e respondeu; fechou com código 0. A conferência visual da tela não foi feita por mim.

**4. Problemas e limitações**

- Listas de eventos corporativos da B3 e da brapi estão incompletas (ver `FONTES_DE_DADOS.md` §1).
- Limites do Finnhub e cobertura do Twelve Data não confirmados em fonte oficial.
- Endpoints de proventos do site da B3 não são API documentada.
- O ícone do executável ainda é o padrão do Flutter (o `.ico` será gerado a partir do símbolo na F2/F7).

**5. Pendências**

- Confirmar Finnhub e Twelve Data com chaves reais (Fase 6).
- Conferir licenças do CKAN do Tesouro e do portal da CVM (Fase 6).
- Toolchain Android incompleta (`cmdline-tools` e licenças); só importa no futuro.

**6. Como executar e o que testar manualmente**

```powershell
flutter run -d windows
```

ou abra `build\windows\x64\runner\Release\patrion.exe`. Conferir: a janela abre com o título "Patrion", fundo verde-escuro, "PATRION" em dourado e o subtítulo "Investimentos e Patrimônio".

## Pendências e problemas conhecidos

Ver a seção 5 da Fase 1 acima.

## Próximo passo

Fase 2 (Fundação), conforme `docs/SPEC.md` §21.

## Histórico de sessões

| Data | Fase | Resumo |
|---|---|---|
| 2026-10-17 | F1 | Ambiente, fontes de dados, decisões e modelo de dados aprovados; projeto criado e primeiro build Windows |
