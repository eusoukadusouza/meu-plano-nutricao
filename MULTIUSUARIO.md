# Meu Plano — Nutrição

Aplicativo web para registro de quatro refeições, substituições de alimentos, dias de descanso, cardio e musculação, medidas e histórico.

## Estado atual
- **Versão 1:** index.html em GitHub Pages; registros locais no navegador. Mantida sem alterações nesta etapa.
- **Versão 2 multiusuário:** estrutura SQL inicial em `supabase/schema.sql`. Ainda **não está ativa**.
- Próximas etapas: criar projeto Supabase, executar e revisar o SQL, configurar Auth e URLs autorizadas, implementar telas de login e administração, conectar o aplicativo ao banco e testar isolamento entre usuários.
- **Não usar com dados de saúde reais de terceiros até concluir testes de permissões e privacidade.**

## Segurança
- A chave publishable pode ser usada no frontend somente com RLS bem configurada.
- Nunca enviar secret key ou service_role ao repositório.
- Os dados de refeições e medidas são visíveis apenas ao próprio usuário nas políticas iniciais.
- Administrador pode visualizar e editar planos, mas não ler registros de adesão ou medidas; eventual compartilhamento exige definição de consentimento e políticas próprias.
- Testar RLS em contas distintas antes de produção.

## Hospedagem
GitHub Pages: https://eusoukadusouza.github.io/meu-plano-nutricao/

## Observações
Valores de alimentos são estimativas. Os planos da calculadora não substituem avaliação nutricional profissional.
