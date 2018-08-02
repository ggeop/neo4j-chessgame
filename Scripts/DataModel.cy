//Create position nodes
CREATE CONSTRAINT ON (p:Position) ASSERT p.FEN IS UNIQUE;
//Load CSV
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM " file:///Position_Nodes.csv" AS line
MERGE (p: Position{FEN: line.FEN});

//Create Game nodes
CREATE CONSTRAINT ON (g:Game) ASSERT g.GameNumber IS UNIQUE;
//Load CSV
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Game_Nodes.csv" AS line
MERGE (g:Game {GameNumber: line.GameNumber,Black: line.Black,White: line.White, BlackElo: toInteger(line.BlackElo), Date: line.Date, ECO: line.ECO, Event: line.Event, Moves: toInteger(line.Moves), Opening: line.Opening, Result: line.Result, Round: toInteger(line.Round), Site: line.Site, WhiteElo: toInteger(line.WhiteElo)})

//Create relationships between Position - Position
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Move_edge.csv" AS line
MATCH (start_node: Position {FEN: line.starting_position})
MATCH(end_node: Position {FEN: line.ending_position})
CREATE (start_node)-[r:MOVE]->(end_node)
SET  r.Move=line.Move, r.Side=line.Side, r.GameNumber=line.GameNumber

//Create relationships between Game - position_node
USING PERIODIC COMMIT
LOAD CSV WITH HEADERS FROM "file:///Game_Position.csv" AS line
MATCH (games: Game {GameNumber: line.GameNumber})
MATCH (first_node: Position {FEN: line.FEN})
CREATE (games)-[r:MOVE]->(first_node)
SET  r.Move=line.Move, r.Side=line.Side, r.GameNumber=line.GameNumber
