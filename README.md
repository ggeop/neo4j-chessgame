# Chess Board Game

## Original Dataset
Chess is a two-player strategy board game played on a chessboard, a checkered game board with 64 squares arranged in an 8×8 grid. The game is played by millions of people worldwide. Chess is believed to have originated in India sometime before the 7th century.  
 
Play does not involve hidden information. Each player begins with 16 pieces: one king, one queen, two rooks, two knights, two bishops, and eight pawns. Each of the six piece types moves differently, with the most powerful being the queen and the least powerful the pawn. The objective is to checkmate the opponent's king by placing it under an inescapable threat of capture. To this end, a player's pieces are used to attack and capture the opponent's pieces, while supporting each other. During the game, play typically involves making exchanges of one piece for an opponent's similar piece, but also finding and engineering opportunities to trade one piece for two, or to get a better position. In addition to checkmate, the game can be won by voluntary resignation, and there are also several ways a game can end in a draw. 
 
The dataset we have contains the data from 684 chess games played in world chess tournaments. Specifically, the file includes the players' details, the tournaments, the date, the result of the game, as well as all the moves of each game and the positions that occur in the chessboard with each move. 

## Dataset Transformations
At this stage we had to transform our initial data, from a not well formatted text file to a comma separated csv file. In the first stage, we created two different csv files (one for the Game nodes and another one for the Position nodes). In the second stage, we preferred to split these two files in four files, one for each different component. Hence, we created one csv for Game nodes, one for Position nodes, one for Game to first match movement, and one for node to node movements. The transformation implemented in a Jupiter notebook (you can find it attached in the deliverable files). 

## Graph Model
In this point we had to create a graph model. The components of this model are the Game and the Position. The Game node refers to a single unique game of two players each time. The Position nodes can be a large number depends on the duration of the game. The Game node is connected to a Position node by a Move. And the Positions are connected to each other also by a move. As we can see in Figure 1 - Model Components below, the Game node has specific attributes(Black, Date, GameNumber etc.). Also, the Position node has specific attributes(FEN) as well. The “MOVE” that connects the two nodes has also specific attributes(MoveNumber, Side, GameNumber) its self. In Figure 2 - High Level Model View, we can see the high level view of the model, which is how Games are connected with a Position and how the Positions are connected to each other. 

![alt text](https://github.com/ggeop/neo4j-chessgame/blob/master/Photos/Untitled-1-02.png)



![alt text](https://github.com/ggeop/neo4j-chessgame/blob/master/Photos/Untitled-1-01.png)


At this point we would like to mention that we preferred a simple model implementation. Alternatively, we could have create a much more complicated model with more components. For instance, we could have built a graph with different nodes for players (black and white), events and eco. But this approach it would not give us better results in the second part of the assignment but it would give us a more clear representation of the model.

## Data Model Creation
We had to create a graph model in Neo4j platform in order to have the data as a property graph by designing the appropriate entities and assigning the relevant labels, types and properties. 

### Position Nodes
We began by creating the position of the nodes. Generally, all positions on the chessboard are not unique (same positions may occur in several games) but in our case we had to create position nodes uniquely described by their FEN property. In order to achieve that we create a constraint on the position nodes and defined that those nodes are uniquely described by the FEN attribute, in Cypher when you create unique id then it’s automatically create an index. Then we loaded the relevant position file and we merged the position nodes according to the FEN attribute. 


```{cy}
//Create position nodes
CREATE CONSTRAINT ON (p:Position) ASSERT p.FEN IS UNIQUE; 

//Load CSV USING PERIODIC COMMIT 
LOAD CSV WITH HEADERS FROM " file:///Position_Nodes.csv" AS line MERGE (p: Position{FEN: line.FEN}); 
```

![alt text](https://github.com/ggeop/neo4j-chessgame/blob/master/Photos/create_position_nodes.png)


### Game Nodes
After we created the Position nodes we had to create the Game nodes. So, we created the Game nodes with the attribute GameNumber as the unique id and then we loaded the relevant file and we merged the nodes according to their attributes.

```{cy}
//Create Game nodes
CREATE CONSTRAINT ON (g:Game) ASSERT g.GameNumber IS UNIQUE; 
 
//Load CSV USING PERIODIC COMMIT 
LOAD CSV WITH HEADERS FROM "file:///Game_Nodes.csv" 
AS line MERGE (g:Game {GameNumber: line.GameNumber,
               Black: line.Black,
               White: line.White, 
               BlackElo: toInteger(line.BlackElo), 
               Date: line.Date, 
               ECO: line.ECO, 
               Event: line.Event, 
               Moves: toInteger(line.Moves), 
               Opening: line.Opening, 
               Result: line.Result, 
               Round: toInteger(line.Round), 
               Site: line.Site, 
               WhiteElo: toInteger(line.WhiteElo)}) 
```

![alt text](https://github.com/ggeop/neo4j-chessgame/blob/master/Photos/create_game_nodes.png)


### Create Position-Position Relationships 
Now it is time to create the relationships between the Position nodes. That will indicate how a move is a connection between two consecutive Position nodes. We match the two Position nodes each time using FEN. Then we create directed relationships between the nodes, and that relationship is called a MOVE. 

```{cy}
//Create relationships between Position - Position 
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Move_edge.csv" AS line MATCH (start_node: Position {FEN: line.starting_position}) 

MATCH(end_node: Position {FEN: line.ending_position}) 
CREATE (start_node)-[r:MOVE]->(end_node) 
SET  r.Move=line.Move, r.Side=line.Side, r.GameNumber=line.GameNumber 
```

![alt text](https://github.com/ggeop/neo4j-chessgame/blob/master/Photos/Create_positon-position.PNG)

### Create Game-Position Relationships
Finally, we had to create the relationships between Games and Position nodes. Hence, we matched the games using the GameNumber and the first positions using FEN which are the unique ids. Then, we create the move that indicates how a Game node is connected to a Position node. And finally, we create the set of the properties again. 

```{cy}
//Create relationships between Game - position_node 
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Game_Position.csv" AS line MATCH (games: Game {GameNumber: line.GameNumber}) 
MATCH (first_node: Position {FEN: line.FEN}) CREATE (games)-[r:MOVE]->(first_node) 
SET  r.Move=line.Move, r.Side=line.Side, r.GameNumber=line.GameNumber 
```

### Final Model
Finally, we have a model as we have represented in the (Figure 1 - Model Components, Figure 2 - High Level Model View). We have all the Games with all their details as Game nodes, which they are connected with the first movement of the game and then all the successive game positions are connected with a directed relationship. In the Figure 12 - A graphical representation of the Nodes and their relationships we can see how the general structure of the model is. The blue node is a game and the green nodes are chess board positions. 

We can observe that as the match is in the beginning the movements of the players are very specific. As you can see there are a lot of games that they have played the first 5 position sequence of movements and then then density of games for specific FEN (standard notation for describing a particular board position of a chess game) is becoming smaller. It’s very normal because Chess is infinite. 
 
 There are 400 different positions after each player makes one move apiece. There are 72,084 positions after two moves apiece. There are 9+ million positions after three moves apiece. There are 288+ billion different possible positions after four moves apiece. There are more 40-move games on Level-1 than the number of electrons in our universe. There are more game-trees of Chess than the number of galaxies (100+ billion), and more openings, defenses, gambits, etc. than the number of quarks in our universe! 
