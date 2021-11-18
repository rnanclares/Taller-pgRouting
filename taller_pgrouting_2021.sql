# Queries del taller de pgRouting

# Arreglamos algunos datos nulos en la capa costarica.ways
# arreglamos valores nulos en el campo cost
select *
from costarica.ways w
where w.length_m is null;

update costarica.ways w
set length_m = st_length(the_geom::geography)
where  w.length_m is null;

# arreglamos valores nulos en el campo cost
select *
from costarica.ways w
where w.cost_s is null;

update costarica.ways w
set cost_s = 0
where  w.cost_s is null;

update costarica.ways w
set reverse_cost_s = 0
where  w.reverse_cost_s is null;


# Comenzamos con el cálculo de rutas usando pgr_dijkstra

SELECT * FROM pgr_dijkstra('SELECT gid as id,
         source,
         target,
         length_m AS cost
        FROM costarica.ways',
    79012, 35280,
    directed := false)
    
    
WITH ruta as (SELECT * FROM pgr_dijkstra(
    'SELECT gid as id,
         source,
         target,
         length_m AS cost
        FROM costarica.ways',
    79012, 35280,
    directed := false))
SELECT ruta.*, w.the_geom
FROM ruta
LEFT JOIN costarica.ways w ON ruta.edge = w.gid ;

# Varios origenes

 SELECT * FROM pgr_dijkstra('SELECT gid as id,
         source,
         target,
         length_m AS cost
        FROM costarica.ways',
    ARRAY[3443, 79012], 35280,
    directed := false)

WITH ruta as (SELECT * FROM pgr_dijkstra(
    'SELECT gid as id,
         source,
         target,
         length_m AS cost
        FROM costarica.ways',
    ARRAY[3443, 79012], 35280,
    directed := false))
SELECT ruta.*, w.the_geom
FROM ruta
LEFT JOIN costarica.ways w ON ruta.edge = w.gid;

# Un solo origen y varios destinos

SELECT * FROM pgr_dijkstra('SELECT gid as id,
         source,
         target,
         length_m / 5.56 AS cost
        FROM costarica.ways',
    154802, ARRAY[149541, 267],
    directed := false);
    
WITH ruta as (SELECT * FROM pgr_dijkstra('SELECT gid as id,
        source,
        target,
        length_m / 5.56 AS cost
       FROM costarica.ways',
   154802, ARRAY[149541, 267],
   directed := false))
SELECT ruta.*, b.the_geom
FROM ruta
LEFT JOIN costarica.ways b ON ruta.edge = b.gid;

# Dirigido
WITH ruta as (SELECT * FROM pgr_dijkstra('SELECT gid as id,
        source,
        target,
        length_m / 5.56 AS cost
       FROM costarica.ways',
   154802, ARRAY[149541, 267],
   directed := true))
SELECT ruta.*, b.the_geom
FROM ruta
LEFT JOIN costarica.ways b ON ruta.edge = b.gid;

# Multiples origines y multiples destinos 

SELECT * FROM pgr_dijkstra('SELECT gid as id,
         source,
         target,
         length_m / 5.56 / 60 AS cost
        FROM costarica.ways',
    ARRAY[154802, 176389], ARRAY[149541, 267],
    directed := false);
   
WITH ruta as (SELECT * FROM pgr_dijkstra('SELECT gid as id,
        source,
        target,
        length_m / 5.56 / 60 AS cost
       FROM costarica.ways',
   ARRAY[154802, 176389], ARRAY[149541, 267],
   directed := false))
SELECT ruta.*, w.the_geom
FROM ruta
LEFT JOIN costarica.ways w ON ruta.edge = w.gid;


# Matrices de costo con pgr_dijkstraCost

SELECT * FROM pgr_dijkstraCost('SELECT gid as id,
        source,
        target,
        length_m / 5.56 / 60 AS cost
       FROM costarica.ways',
   ARRAY[154802, 176389], ARRAY[149541, 267],
   directed := false)
   
SELECT start_vid, sum(agg_cost) as tiempo_total
FROM pgr_dijkstraCost('SELECT gid as id,
        source,
        target,
        length_m / 5.56 / 60 AS cost
       FROM costarica.ways',
   ARRAY[154802, 176389], ARRAY[149541, 267],
   directed := false)
GROUP BY start_vid
ORDER BY start_vid;


select pgr_dijkstraCost('SELECT gid as id,
        source,
        target,
        length_m / 5.56 / 60 AS cost
       FROM costarica.ways',
   ARRAY[154802, 176389], ARRAY[149541, 267],
   directed := false)
   
   
# Ruteo para vehículos
# Ejercicio 7 - Ida

SELECT * FROM pgr_dijkstra('SELECT gid as id,
         source,
         target,
         cost,
         reverse_cost
        FROM costarica.ways',
    154802, 149541,
    directed := true);

   
WITH ruta as (SELECT * FROM pgr_dijkstra(
    'SELECT gid as id,
         source,
         target,
         cost,
         reverse_cost
        FROM costarica.ways',
    154802, 149541,
    directed := true))
SELECT ruta.*, b.the_geom
FROM ruta
LEFT JOIN costarica.ways b ON ruta.edge = b.gid;

# Ejercicio 8 - Regreso

SELECT * FROM pgr_dijkstra('SELECT gid as id,
         source,
         target,
         cost,
         reverse_cost
        FROM costarica.ways',
     149541, 154802,
    directed := true);

WITH ruta as (SELECT * FROM pgr_dijkstra(
    'SELECT gid as id,
         source,
         target,
         cost,
         reverse_cost
        FROM costarica.ways',
    149541, 154802,
    directed := true))
SELECT ruta.*, b.the_geom
FROM ruta
LEFT JOIN costarica.ways b ON ruta.edge = b.gid;

# Ejercicio 9 - El tiempo es oro
SELECT * FROM pgr_dijkstra('SELECT gid as id,
         source,
         target,
         cost_s * 1000 / 3600 as cost,
         reverse_cost_s * 1000 / 3600 as reverse_cost
        FROM costarica.ways',
    154802, 149541,
    directed := true);
   
WITH ruta as (SELECT * FROM pgr_dijkstra(
    'SELECT gid as id,
         source,
         target,
         cost_s * 1000 / 3600 as cost,
         reverse_cost_s * 1000 / 3600 as reverse_cost
        FROM costarica.ways',
    154802, 22833,
    directed := true))
SELECT ruta.*, b.the_geom
FROM ruta
LEFT JOIN costarica.ways b ON ruta.edge = b.gid;

# Ejercicio 10

SELECT tag_id, tag_key, tag_value
FROM costarica.configuration
ORDER BY tag_id;



