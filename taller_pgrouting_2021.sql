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

ALTER TABLE costarica.configuration ADD COLUMN penalty FLOAT;

-- Sin penalización
UPDATE costarica.configuration SET penalty=1;

WITH ruta as (SELECT * FROM pgr_dijkstra('
    SELECT gid AS id,
        source,
        target,
        cost_s * penalty AS cost,
        reverse_cost_s * penalty AS reverse_cost
    FROM costarica.ways JOIN costarica.configuration
    USING (tag_id)',
    154802, 22833,
   directed := true))
SELECT ruta.*, b.the_geom
FROM ruta
LEFT JOIN costarica.ways b ON ruta.edge = b.gid;

--- Vamos a modificar el penalty de las vías primarias
UPDATE costarica.configuration SET penalty=100 WHERE tag_value = 'primary';

WITH ruta as (SELECT * FROM pgr_dijkstra('
    SELECT gid AS id,
        source,
        target,
        cost_s * penalty AS cost,
        reverse_cost_s * penalty AS reverse_cost
    FROM costarica.ways JOIN costarica.configuration
    USING (tag_id)',
    154802, 22833,
   directed := true))
SELECT ruta.*, b.the_geom
FROM ruta
LEFT JOIN costarica.ways b ON ruta.edge = b.gid;


-- Ejercicio 11

ALTER TABLE costarica.hospitales
ADD COLUMN id_nodo integer,
ADD COLUMN distancia integer;

WITH foo as (
SELECT
hospitales.gid,
closest_node.id,
closest_node.dist
FROM costarica.hospitales
CROSS JOIN LATERAL -- Este CROSS JOIN lateral funciona como un bucle "for each"
(SELECT
 id,
 ST_Distance(wvp.the_geom::geography, hospitales.geom::geography) as dist
 FROM costarica.ways_vertices_pgr wvp 
 ORDER BY wvp.the_geom <-> hospitales.geom
 LIMIT 1 -- Este limit 1 hace que solo obtengamos el nodo más cercano de la red
) AS closest_node)
UPDATE costarica.hospitales -- Finalmente actualizamos la capa de hospitales
SET id_nodo = foo.id,
distancia = foo.dist
FROM foo
WHERE hospitales.gid = foo.gid;

-- Puntos (nodos)
select
	row_number() over (order by seq) as gid, 
    subquery.seq,
	subquery.node,
	subquery.edge,
	subquery.cost,
	subquery.aggcost,
	wvp.the_geom as geom
FROM pgr_drivingDistance('SELECT
     gid as id,
     source,
     target,                                    
     cost_s AS cost
     FROM costarica.ways', 155390, 1800, false)
     subquery(seq, node, edge, cost, aggcost)
JOIN costarica.ways_vertices_pgr wvp ON subquery.node = wvp.id;

-- Lineas (edges)
SELECT 
	row_number() over (order by seq) as gid, 
	subquery.seq,
	subquery.node,
	subquery.edge,
	subquery.cost,
	subquery.aggcost,
	w.the_geom as geom
FROM pgr_drivingDistance('SELECT
     gid as id,
     source,
     target,                                    
     cost_s AS cost
     FROM costarica.ways', 155390, 1800, false)
     subquery(seq, node, edge, cost, aggcost)
JOIN costarica.ways w ON subquery.edge = w.gid;

-- Ejercicio 12

WITH ruteo as (
  select
    subquery.seq,
  	subquery.start_v,
  	subquery.node,
  	subquery.edge,
  	subquery.cost,
  	subquery.aggcost,
  	wvp.the_geom as geom
  FROM pgr_drivingDistance('SELECT
       gid as id,
       source,
       target,                                    
       cost_s AS cost
       FROM costarica.ways',
       array(SELECT id_nodo FROM costarica.hospitales
       where nombre in ('HOSPITAL SAN VICENTE PAUL HEREDIA', 'HOSPITAL SAN RAFAEL DE ALAJUELA')), 1800, false)
       subquery(seq, start_v, node, edge, cost, aggcost)
  JOIN costarica.ways_vertices_pgr wvp ON subquery.node = wvp.id)
SELECT node, geom, min(aggcost) AS aggcost
FROM ruteo
GROUP By node, geom;

-- Ejercicio 13

-- pgr_alphaShape
with subquery as (
    SELECT st_collect(wvp.the_geom) as geom
    FROM pgr_drivingDistance('SELECT 
			gid As id, 
			source,
			target,
            cost_s AS cost,
			reverse_cost_s as reverse_cost
            FROM costarica.ways', array(SELECT id_nodo FROM costarica.hospitales
       where nombre in ('HOSPITAL SAN VICENTE PAUL HEREDIA', 'HOSPITAL SAN RAFAEL DE ALAJUELA')), 450, false) AS di
     INNER JOIN costarica.ways_vertices_pgr AS wvp ON di.node = wvp.id
) select pgr_alphashape(geom, 1.5) as alphaGeom
from subquery;

-- ST_ConcaveHull

with subquery as (
    SELECT st_collect(wvp.the_geom) as geom
    FROM pgr_drivingDistance('SELECT 
			gid As id, 
			source,
			target,
            cost_s AS cost,
			reverse_cost_s as reverse_cost
            FROM costarica.ways',array(SELECT id_nodo FROM costarica.hospitales
       where nombre in ('HOSPITAL SAN VICENTE PAUL HEREDIA', 'HOSPITAL SAN RAFAEL DE ALAJUELA')), 450, false) AS di
     INNER JOIN costarica.ways_vertices_pgr AS wvp ON di.node = wvp.id
)


-- Ejercicio 14

ALTER TABLE costarica.hospitales
ADD COLUMN id_nodo integer,
ADD COLUMN distancia integer;

WITH foo as (
SELECT
lugares.gid,
closest_node.id,
closest_node.dist
FROM costarica.lugares
CROSS JOIN LATERAL
(SELECT
 id,
 ST_Distance(wvp.the_geom::geography, lugares.geom::geography) as dist
 FROM costarica.ways_vertices_pgr wvp 
 ORDER BY wvp.the_geom <-> lugares.geom
 LIMIT 1 -- Este limit 1 hace que solo obtengamos el nodo más cercano de la red
) AS closest_node)
UPDATE costarica.lugares
SET id_nodo = foo.id,
distancia = foo.dist
FROM foo
WHERE lugares.gid = foo.gid;


CREATE TABLE costarica.localidadesVShospitales as (SELECT *
  FROM pgr_dijkstraCost(
      'SELECT gid as id,
           source,
           target,
           cost_s as cost
          FROM costarica.ways',
      array(SELECT id_nodo FROM costarica.lugares),
      array(SELECT id_nodo FROM costarica.hospitales),
      directed := false));
     
CREATE TABLE costarica.locpobvshospitalesrank as ( 
    SELECT foo.* FROM (
        SELECT localidadesVShospitales.*, rank() over (partition BY start_vid ORDER BY agg_cost asc)
FROM costarica.localidadesVShospitales) foo WHERE RANK <= 3);

CREATE TABLE costarica.matriz_locpobVShospitales as (
	SELECT row_number() over (order by a.start_vid) as id,
	a.start_vid as nodo_inicio,
	b."name" as localidad,
	a.end_vid as nodo_fin,
	c.nombre as hospital,
	a."agg_cost" / 60 as tiempo_minutos,
	a."rank",
	st_makeline(b.geom,c.geom) as geom
FROM costarica.locpobvshospitalesrank a
LEFT JOIN costarica.lugares b ON a.start_vid = b.id_nodo
LEFT JOIN costarica.hospitales c ON a.end_vid = c.id_nodo);



