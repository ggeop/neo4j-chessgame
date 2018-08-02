###Queries
1)
MATCH (a:Position)-[b:MOVE]-> (c:Position{FEN:'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})
WITH COUNT (DISTINCT b.GameNumber) AS Total , COLLECT(b.GameNumber) as Collection
MATCH (g:Game)
WHERE g.GameNumber IN Collection AND g.Result='White'

RETURN toFloat(count(*))/Total*100 AS Percentage, Total AS Count


2)
MATCH (a:Position)-[b:MOVE] -> (c:Position{FEN:'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})
WITH COLLECT(b.GameNumber) AS Collection

MATCH (g:Game)
WHERE g.GameNumber IN Collection AND g.Result='Draw'
WITH count(g) AS Draws, Collection

MATCH (g:Game)
WHERE g.GameNumber IN Collection AND g.Result='White'
WITH count(g) AS Whites, Draws, Collection

MATCH (g:Game)
WHERE g.GameNumber IN Collection AND g.Result='Black'
WITH count(g) AS Blacks, Whites, Draws

RETURN Blacks, Whites, Draws


3)
MATCH (g:Game)
WITH  g.Event AS Event, Count(g) AS COUNT1
ORDER BY COUNT1 DESC
WITH COLLECT([Event,COUNT1]) AS Collection
UNWIND(Collection) AS list
WITH max(list[1]) AS max, Collection
UNWIND(Collection) AS h
WITH COLLECT(h) AS Events,COLLECT(h[1]) AS Score
WITH Score[1] AS Max, Events
UNWIND Events AS Ev

MATCH (g2:Game)
WHERE g2.Event IN Ev[0]  AND (g2.White='Karpov  Anatoly' OR g2.Black='Karpov  Anatoly') AND Ev[1]=Max
WITH COUNT (DISTINCT g2.GameNumber) AS GamesWithKarpov,g2.Event as Event,Max AS TotalGames

RETURN Event,TotalGames,GamesWithKarpov

4)
MATCH (g:Game{Opening:'Ruy Lopez'})
WITH COLLECT([g.Black,g.White]) AS Collection
UNWIND Collection AS Players_tuples
UNWIND Players_tuples AS Players
WITH Players, COUNT(Players) AS Count
ORDER BY Count DESC
WITH COLLECT([Players,Count]) AS Collection1
UNWIND(Collection1) AS list
WITH max(list[1]) as max, Collection1
UNWIND(Collection1) AS h
WITH h,max
WHERE h[1]=max

RETURN COLLECT(h[0]) AS Players


5)
MATCH (a:Position)-[b:MOVE{Move:'Nc6'}]->(c:Position)-[d:MOVE{Move:'Bb5'}]-> (e:Position)-[f:MOVE{Move:'a6'}]->(g:Position)
WITH COLLECT(f.GameNumber) as Collection, COUNT (DISTINCT f.GameNumber) AS Total_Games

MATCH (g:Game)
WHERE g.GameNumber IN Collection
WITH Total_Games, g.Black AS Player1, g.White AS Player2

RETURN Total_Games, Player1,  Player2


6)
MATCH(g:Game{GameNumber:'636'}) WITH g
MATCH (g)-[m1:MOVE{GameNumber:'636'}]->(a:Position)
WITH COLLECT(m1.Move) AS List1,g

MATCH (b:Position)-[m2:MOVE{GameNumber:'636'}]->(c:Position)
WITH COLLECT(m2.Move) AS List2, List1, g

RETURN g AS GameDetails,(List1+List2) AS Moves


7)
MATCH (a:Position)-[b:MOVE]-> (c:Position{FEN:'r1bqkbnrpppp1ppp2n51B2p34P35N2PPPP1PPPRNBQK2R'})-[d:MOVE]-> (e:Position)
WHERE d.Move <> 'a6'
WITH COLLECT(d.GameNumber) as Collection,d.Move as AlternativeMove

MATCH (g:Game)
WHERE  g.GameNumber IN Collection

RETURN g.GameNumber as Game, g.Result as Result, AlternativeMove
