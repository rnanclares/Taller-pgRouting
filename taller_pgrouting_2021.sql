# Queries del taller de pgRouting

# Arreglamos algunos datos nulos en la capa costarica.ways

select *
from costarica.ways w
where w.length_m is null;

update costarica.ways w
set length_m = st_length(the_geom::geography)
where  w.length_m is null;

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


