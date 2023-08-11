# implementacion-dunha-arquitectura
<!--
Nesta segunda práctica, debes elixir unha das arquitecturas que
estudamos na materia (distribuída ou non), agas o cliente/servidor, e
implementar un proxecto Elixir que a empregue.

A funcionalidade do sistema non é relevante, non tes que implementar
lóxica de negocio. O primordial é que o proxecto inclúa os componentes
habituais na arquitectura que elixas, e que estes se comuniquen entre
si tal e como dicta a arquitectura.

O repositorio debe conter:

-  O código fonte do proxecto en Elixir, coa estrutura habitual dos
   proxectos nesta tecnoloxía (isto é, a que se obtén empregando o
   comando `mix new`)

   O código fonte debe estar formateado usando `mix format`

-  A representación C4 incluíndo todos os niveis, en formato PNG/JPG
   ou PDF, nun directorio doc

-  Unha descrición detallada sustituíndo este README que inclúa a
   arquitectura elixida e como executar e probar o sistema

-  O nome da equipa e os seus integrantes neste README
-->



### A arquitectura elexida foi una arquitectura peer to peer.

Esta arquitectura foi implementada ca versión do Super Peer, de tal maneira que dado un peer creado podemos 
engadilo a outro ou a un grupo de veciños dado, todos dado grupo compartirán información entre eles, cada peer pode 
consultar o seu estado, conectarse con outros, e buscar un elementos dado para añadilo ao seu rexistro.

No caso de que a info que busca un peer non se atope no seu grupo de veciños, lanzaraselle unha proposta a ese peer
de conectarse co super peer (si non o está xa), no caso de que así sea utilizarse o super peer, que ten
un rexistro de todos os peers e por lo tanto de todos os grupos de veciños, busca neles a información requerida, se a atopa
devolvella ao peer.

Usamos un pequeno sistema de usuarios con funcións "register" e "login" para que cada usuario poida crear peers, conectalos
entre eles, buscar informacion e añadila manualmente.


Para correr a aplicacion introducimos os seguintes comandos nun terminal:

**iex -S mix**

**App.start**

**App.register("usuario")**

**App.login("usuario")**

#pediraseche se quieres crear un primeiro peer

#y para crear ese peer 

_$ **y**

#A continuación volverás ao iex de novo, terás que "logear" de novo

**App.login("usuario")**

#A continuacion mostraranseche todas as posibles opcións:

**connect -peer**
   - A lista de peers pode verse na cabeceira cada vez que se realiza unha función.
   - Conectarse a un peer en especificos dos que o usuario "usuario" ten creados [0...N]. Por exemplo: _$ **connect 0**

**accountsyncronize**
   - Conecta os peers entre eles, todos os da "conta" de usuario. Modo de emprego: _$ **accountsyncronize**

**syncronizewith -usuario**
   - Sincroniza todos os peers dun usuario cos de outro dado. Exemplo: _$ **syncronizewith "usuario2"**

**createpeer**
   - Crea un peer asociado ao usuario que o crea: Modo de emprego: _$ **createpeer**



#Unha vez conectado ao peer, o usuario poderá executar os seguintes comandos:

**find -item**		

   - Intenta atopar o obxeto X, primeiro buscará nos veciños, se non atopa preguntará se 
queremos conectarnos ao super peer para buscar nos demáis grupos de peers, responderemos en caso
afirmativo con:  _$ **y**  .Modo de emprego:  _$ **find libro1**

**save**			

   - Garda o elemento dado no peer que estamos a empregar. Exemplo: _$ **save libro1**

**getvolume**

   - Devolve a listaxe de elementos que ten o peer almacenados

**getneighboor**		

   - Devolve os veciños do peer dado


#Se queremos voltar de un peer ás opcions de usuario ou das opcions de usuario ao iex, sempre podemos usar:

_$ **exit**



- equipo iron maiden
- Alejandro Ariza Abaña - alejandro.ariza@udc.es
- Ángel Otero Barreiros - angel.barreiros@udc.es

