# dwd12
DWD12 - Password generator based in Diceware

Diceware é um método de criação de senhas elaborado por Arnold Reinhold e publicado em 1995. Nesse método, você sorteia algumas palavras (geralmente entre 4 e 8 palavras) a partir de uma lista enorme (uma lista de 7.776 palavras para ser exato) utilizando dados comuns, de seis faces, e esta é sua senha. Mesmo a lista total sendo pública, a chance de ser quebrada é pequena, pois é de 1 em x ^ y, sendo x o total de palavras da lista e y o número de sorteios. A chance de adivinhar uma senha de 5 palavras em uma tentativa, por exemplo, é de 1 em 7.776 ^ 5, o que dá 1 em 28.430.288.029.929.701.376! Ou aproximadamente 1 em 2,8 * 10 ^ 19! Cada palavra é sorteada a partir de 5 rolagens de dados. Você pode entender melhor a proposta lendo o artigo de Micah Lee para The Intercept, entitulado Senhas fáceis para você memorizar e que nem a NSA conseguirá desvendar.

A proposta Diceware D12 (ou DW12) é de uma variante do Diceware tradicional, com algumas diferenças marcantes:

    Uso de dados de 12 faces. Dados de 12 faces oferecem individualmente um número bom de possibilidades. Podem ser substituídos por 2 rolagens de um dado de 6 faces ou mesmo por um baralho após uma adaptação rápida. Embora incomuns, estão presentes em qualquer “conjunto de dados para RPG”.
    Ao invés de uma lista única de palavras, o DW12 utiliza o conceito de tomos. Antes de sortear, você escolhe tomos de onde será feito o sorteio. Cada tomo contém 1.728 palavras, de modo que o uso de 5 tomos já supera o Diceware tradicional em entropia (totaliza 8.640 palavras). Sem contar que para tentar quebrar sua senha, mesmo que o atacante conheça o método DW12, ele não saberá que subconjunto de tomos você utilizou. E a senha se torna ainda mais difícil se utilizamos um “tomo secreto”.

Este projeto fornecerá maneira automatizada de gerar senhas e criar/gerenciar tomos.
