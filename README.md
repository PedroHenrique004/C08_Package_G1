# Como ultilizar o package

 ### Olá futuro desenvolvedor, incluimos novas funcionalidades no nosso Package!! 🥳

- Oque tinha antes:
Nosso pacote, faz a análise de imagens de um modelo que retorna boolean se é ou nao um Pet.

- Oque tem de novo:
Além de retornar se é um Pet ou não, agora ele pode retornar o tipo, dizendo qual animal é  ( Cachorro, Hamster, Gato e papagaio )

## Oque pode retornar:
 
 ### Verdadeiro
1. Retorna se é ou não Pet ( Cachorro, Hamster, Gato e papagaio )
2. Retorna também o tipo do animal ( Cachorro, Hamster, Gato e papagaio )
   
 ### False
1. caso a foto/imagem seja de um algo que não é um pet (Todo o resto, neste caso)
 
## Para utilizar nosso packege em seu código:
     Task{
             let manager = PackageManager()
             let model: ResponseAnalyze = await manager.analyze(image: UIImage())
         }
 
 ### Você receberá um modelo que contém um nome em um string, se quiser que ele retorne o nome do Pet use isso:
 ```bash
       //Acessar o tipo do animal: true = Domestico, false = não domestico
           model.isPet
      //Acessar o nome do animal:
           model.name
```
 
 

 


