# Ativação do administrador Caxias

Conta solicitada: martoandre.a.j2@gmail.com. Criada exclusivamente por API administrativa Auth no projeto Caxias. Perfil dono ativo vinculado pelo UUID da conta no banco Caxias. Senha inicial aleatória não entregue nem copiada do Torres.

Página definir-senha-caxias.html recebe token de recuperação em fragmento, remove-o da URL e só o verifica ao enviar nova senha. Credenciais apenas em memória, comunicação exclusivamente com Caxias. Link de uso único não armazenado no repositório.

Provisionamento por função temporária protegida por segredo aleatório de 256 bits, destino e e-mail fixos, com expiração. Após execução, substituída por resposta 410 e validação JWT habilitada. Nenhuma operação no Torres.

Testes da lógica de ativação: ausência de link, senha curta, confirmação diferente, link expirado, alteração bem-sucedida simulada e repetição após falha de atualização. Login real com senha definitiva depende da ativação pelo usuário.
