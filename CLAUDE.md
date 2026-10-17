# CLAUDE.md — Patrion

Instruções permanentes para o Claude Code neste repositório. No início de toda sessão, leia este arquivo e `docs/PROGRESS.md`.

## O projeto

Aplicativo desktop pessoal para Windows 10 e 11 que registra, acompanha, analisa e simula investimentos. Ele é usado diariamente por um único usuário, em dois ou mais computadores, sincronizados por arquivo e sem servidor. Android e iOS vêm no futuro: não desenvolva agora, mas não crie obstáculos para isso.

- Especificação completa: `docs/SPEC.md`
- Decisões técnicas: `docs/DECISIONS.md`
- Estado atual: `docs/PROGRESS.md`
- Casos de teste de referência: `docs/CASOS_DE_TESTE.md`

## Ambiente

- Desenvolvimento e execução no Windows, com PowerShell. Os comandos precisam funcionar no PowerShell.
- Flutter no canal stable, com a versão fixada em `DECISIONS.md` e no CI.
- Instalador gerado com Inno Setup 6.
- Repositório em Git + GitHub. CI no GitHub Actions com runner `windows-latest`.

## Stack (não trocar sem minha autorização)

- Flutter/Dart com Flutter Desktop para Windows.
- SQLite via Drift, com migrações versionadas.
- Riverpod.
- Dio.
- Tipo decimal para dinheiro (pacote `decimal` ou equivalente registrado em `DECISIONS.md`).

Para gráficos, PDF, XLSX e outras bibliotecas, escolha avaliando manutenção, licença e suporte a Windows, e registre a escolha em `DECISIONS.md` antes de usar.

## Arquitetura

```
lib/
  core/            configuração, datas, moedas, erros, utilitários, HLC
  domain/          entidades, regras e cálculos financeiros (Dart puro)
  application/     casos de uso
  data/            repositórios, tabelas Drift, DAOs
  infrastructure/  APIs externas, arquivos, backup, save, sistema
  presentation/    telas e widgets
test/              unitários, integração e widget (espelhando lib/)
```

- `domain/` não importa Flutter, Drift, Dio nem nenhum provedor de dados.
- Cada provedor de dados externo é um adaptador atrás de uma interface.

## Regras invioláveis

1. Nunca invente cotações, indicadores, séries históricas ou resultados. Sem dado, mostre "indisponível". Um dado antigo aparece com a data de referência, nunca como atual.
2. Todo dado de mercado guarda a fonte, a data de referência, a data de coleta e o tipo (fechamento, intradiário, ajustado, estimado ou calculado).
3. Simulações e projeções são sempre rotuladas como hipotéticas, nunca como previsão ou recomendação.
4. Carteira real e carteiras hipotéticas têm tabelas, operações e totais separados. Nenhuma simulação altera dados reais, e o patrimônio hipotético nunca entra no dashboard real.
5. Os dados do usuário ficam fora da pasta de instalação, na pasta de dados do usuário do Windows, e sobrevivem a atualização, reinstalação e desinstalação.
6. Valores monetários nunca usam `double`. O arredondamento é definido e documentado. Única exceção: converter `Decimal` para `double` em `presentation/`, só para desenhar gráficos; nunca em cálculos nem em persistência (`DECISIONS.md` D-03).
7. Nada de segredos no código ou no repositório. Chaves de API ficam nas configurações locais. Os logs não registram valores patrimoniais.
8. Nunca envie a carteira a serviços externos. As requisições levam só os tickers e séries necessários.
9. Só diga que algo funciona, compila ou passou nos testes depois de executar e ver o resultado. Se não conseguiu executar, diga isso explicitamente.
10. Fórmulas financeiras ficam documentadas em `docs/FORMULAS.md` e cobertas por testes.

## Dados prontos para sincronização (desde a primeira tabela)

Toda tabela com dados do usuário (tabela "sincronizável") tem estes campos:

- `id` (TEXT): UUID v7 gerado no app. Nunca use autoincremento como identidade.
- `created_at` e `updated_at`: em UTC.
- `hlc`: Hybrid Logical Clock da última alteração.
- `device_id`: dispositivo que fez a última alteração.
- `deleted_at`: exclusão lógica (tombstone). Registros sincronizáveis nunca são apagados fisicamente.

Toda escrita passa por repositórios que preenchem esses campos automaticamente. Dados derivados (posições, métricas, caches de cálculo) não são sincronizáveis: eles são recalculados. Os detalhes estão em `docs/SPEC.md` §10.

## Forma de trabalhar

- Trabalhe somente na fase pedida. Dentro dela, resolva detalhes secundários por boas práticas sem parar para perguntar, e registre as decisões relevantes em `DECISIONS.md`.
- Pergunte antes de:
  - trocar a stack;
  - mudar o schema de forma incompatível;
  - apagar dados;
  - reduzir o escopo de uma fase;
  - seguir quando uma fonte de dados se mostrar inviável.
- Antes de considerar uma etapa pronta, rode e confirme:
  - `dart format`;
  - `flutter analyze` sem erros;
  - `flutter test` passando;
  - `flutter build windows` compilando.
- Faça commits pequenos, em português, no padrão Conventional Commits (`feat:`, `fix:`, `test:`, `docs:`, `refactor:`). Commits locais são livres. `push`, tags e Releases só quando eu pedir.
- Nunca versione bancos (`.sqlite`, `.db`), backups, arquivos `.invsave`, `.env` ou chaves.
- Se o contexto da sessão ficar grande, atualize `PROGRESS.md` e me avise para iniciar uma nova sessão.

## Relatório ao final de cada fase (também registrado em PROGRESS.md)

1. O que foi implementado.
2. Arquivos criados ou alterados (resumo).
3. Testes executados e resultados reais.
4. Problemas e limitações.
5. Pendências.
6. Como executar e o que eu devo testar manualmente.

## Comandos

Atualize esta lista quando os comandos mudarem.

```powershell
flutter pub get
dart run build_runner build
dart run drift_dev make-migrations   # depois de mudar o schema
dart run tool/gen_app_icon.dart     # depois de mudar o símbolo SVG
dart format .
flutter analyze
flutter test
flutter run -d windows
flutter build windows --release
```
