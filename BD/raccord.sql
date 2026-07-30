--
-- PostgreSQL database dump
--

\restrict Lj1AvXA4QETtEgH7URwyV2assKAVRgJPh0uMzPeqHGZdqPU0RTYwOwHrhRKd0op

-- Dumped from database version 18.2 (Debian 18.2-1.pgdg13+1)
-- Dumped by pg_dump version 18.2 (Debian 18.2-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: estado_guion; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.estado_guion AS ENUM (
    'Borrador',
    'Revisión',
    'Aprobado',
    'En Rodaje',
    'Archivado'
);


ALTER TYPE public.estado_guion OWNER TO admin;

--
-- Name: estado_usuario; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.estado_usuario AS ENUM (
    'activo',
    'inactivo',
    'pendiente',
    'suspendido'
);


ALTER TYPE public.estado_usuario OWNER TO admin;

--
-- Name: formatos; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.formatos AS ENUM (
    'serie',
    'miniserie',
    'pelicula',
    'largometraje',
    'mediometraje',
    'cortometraje',
    'documental',
    'spot publicitario',
    'video musical',
    'video corporativo',
    'video educativo',
    'micro-formato',
    'mockumentary'
);


ALTER TYPE public.formatos OWNER TO admin;

--
-- Name: generos; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.generos AS ENUM (
    'accion',
    'comedia',
    'aventura',
    'drama',
    'terror',
    'ciencia ficcion',
    'fantasia',
    'suspenso',
    'musical',
    'western',
    'belico',
    'romance',
    'crimen',
    'misterio',
    'animacion',
    'biopic',
    'documental',
    'video',
    'artes marciales',
    'thriller',
    'Histórico',
    'epoca',
    'familiar',
    'deportivo',
    'horror',
    'paranormal',
    'otro'
);


ALTER TYPE public.generos OWNER TO admin;

--
-- Name: generosex; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.generosex AS ENUM (
    'masculino',
    'fenemino',
    'otro'
);


ALTER TYPE public.generosex OWNER TO admin;

--
-- Name: jerarquias_rol; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.jerarquias_rol AS ENUM (
    'productora',
    'direccion',
    'alto',
    'medio',
    'bajo'
);


ALTER TYPE public.jerarquias_rol OWNER TO admin;

--
-- Name: momentodia; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.momentodia AS ENUM (
    'dia',
    'noche',
    'amanecer',
    'atardecer',
    'amanecer/dia',
    'dia/noche'
);


ALTER TYPE public.momentodia OWNER TO admin;

--
-- Name: tipo_documento; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.tipo_documento AS ENUM (
    'CC',
    'TI',
    'NIT',
    'CE',
    'PA'
);


ALTER TYPE public.tipo_documento OWNER TO admin;

--
-- Name: vistalugar; Type: TYPE; Schema: public; Owner: admin
--

CREATE TYPE public.vistalugar AS ENUM (
    'int',
    'ext',
    'int/ext',
    'ext/int'
);


ALTER TYPE public.vistalugar OWNER TO admin;

--
-- Name: gen_id_actor(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.gen_id_actor() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.id_actor := 'act' || nextval('actor_seq');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.gen_id_actor() OWNER TO admin;

--
-- Name: gen_id_departamento(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.gen_id_departamento() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.id_departamento := 'area' || LPAD(nextval('departamento_seq')::text, 2, '0');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.gen_id_departamento() OWNER TO admin;

--
-- Name: gen_id_escena(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.gen_id_escena() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.id_escena := 'esc' || LPAD(nextval('escena_seq')::text, 3, '0');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.gen_id_escena() OWNER TO admin;

--
-- Name: gen_id_personaje(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.gen_id_personaje() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.id_personaje := 'cast' || nextval('personajes_seq');
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.gen_id_personaje() OWNER TO admin;

--
-- Name: generar_id_project(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.generar_id_project() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN 'proj' || LPAD(nextval('project_seq')::TEXT, 4, '0');
END;
$$;


ALTER FUNCTION public.generar_id_project() OWNER TO admin;

--
-- Name: actor_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.actor_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.actor_seq OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: actors; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.actors (
    id_actor text NOT NULL,
    nombre character varying(45) NOT NULL,
    apellido character varying(45) NOT NULL,
    genero public.generosex NOT NULL,
    fecha_de_nacimiento date NOT NULL,
    talla_zapatos character varying(10) NOT NULL,
    ancho_espalda character varying(30) NOT NULL,
    pecho character varying(30) NOT NULL,
    cintura character varying(30) NOT NULL,
    cadera character varying(30) NOT NULL,
    largo_manga character varying(30) NOT NULL,
    largo_pierna character varying(30) NOT NULL,
    talla_anillo text,
    contorno_cabeza character varying(30),
    contorno_cuello character varying(30),
    color_cabello character varying(45) NOT NULL,
    textura_cabello character varying(45) NOT NULL,
    tipo_piel character varying(45) NOT NULL,
    color_ojos character varying(45) NOT NULL,
    alergias text,
    habilidades_especiales text,
    restricciones text,
    comentarios_adicionales text,
    nacionalidad character varying(50) NOT NULL,
    doble_riesgo boolean NOT NULL,
    id_personaje text
);


ALTER TABLE public.actors OWNER TO admin;

--
-- Name: clients; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.clients (
    id_cliente integer NOT NULL,
    document public.tipo_documento NOT NULL,
    razon_social character varying(50) NOT NULL,
    representante_legal character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    address character varying(100) NOT NULL,
    telephone character varying(15),
    number_cellphone character varying(20) NOT NULL,
    id_document text
);


ALTER TABLE public.clients OWNER TO admin;

--
-- Name: clients_id_cliente_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.clients_id_cliente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clients_id_cliente_seq OWNER TO admin;

--
-- Name: clients_id_cliente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.clients_id_cliente_seq OWNED BY public.clients.id_cliente;


--
-- Name: departamento_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.departamento_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.departamento_seq OWNER TO admin;

--
-- Name: departamentos; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.departamentos (
    id_departamento text NOT NULL,
    nombre character varying(45) NOT NULL,
    ubicacion text NOT NULL
);


ALTER TABLE public.departamentos OWNER TO admin;

--
-- Name: desglose_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.desglose_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.desglose_seq OWNER TO admin;

--
-- Name: desgloses; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.desgloses (
    id_desglose text DEFAULT ('desg'::text || nextval('public.desglose_seq'::regclass)) NOT NULL,
    version character varying(50) NOT NULL,
    semana_grabacion integer,
    dia_rodaje integer,
    hora_inicio time without time zone,
    hora_fin time without time zone,
    location character varying(200),
    requerimientos text NOT NULL,
    activo boolean DEFAULT true
);


ALTER TABLE public.desgloses OWNER TO admin;

--
-- Name: escena_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.escena_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.escena_seq OWNER TO admin;

--
-- Name: escenas; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.escenas (
    id_escena text NOT NULL,
    numero_de_escena character varying(45) NOT NULL,
    encabezado text NOT NULL,
    descripcion text,
    id_guion integer,
    modo_vista public.vistalugar,
    momento_dia public.momentodia,
    ciudad text,
    pagina integer,
    fecha_de_grabacion date,
    dia_dramatico integer,
    id_rodaje text,
    id_desglose text
);


ALTER TABLE public.escenas OWNER TO admin;

--
-- Name: escenas_personajes; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.escenas_personajes (
    id_escena text NOT NULL,
    id_personaje text NOT NULL
);


ALTER TABLE public.escenas_personajes OWNER TO admin;

--
-- Name: guiones; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.guiones (
    id_guion integer NOT NULL,
    numero_de_version character varying(45) NOT NULL,
    fecha_de_emision date NOT NULL,
    estado public.estado_guion NOT NULL,
    archivo text NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    id_project text
);


ALTER TABLE public.guiones OWNER TO admin;

--
-- Name: guiones_id_guion_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.guiones_id_guion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.guiones_id_guion_seq OWNER TO admin;

--
-- Name: guiones_id_guion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.guiones_id_guion_seq OWNED BY public.guiones.id_guion;


--
-- Name: permiso_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.permiso_seq
    START WITH 2001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permiso_seq OWNER TO admin;

--
-- Name: permisos; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.permisos (
    id_permiso integer DEFAULT nextval('public.permiso_seq'::regclass) NOT NULL,
    codigo character varying(50) NOT NULL,
    nombre character varying(100) NOT NULL,
    modulo character varying(50),
    descripcion text,
    activo boolean DEFAULT true
);


ALTER TABLE public.permisos OWNER TO admin;

--
-- Name: personajes; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.personajes (
    id_personaje text NOT NULL,
    nombre character varying(45) NOT NULL,
    edad integer NOT NULL,
    codigo_personaje character varying(30) NOT NULL
);


ALTER TABLE public.personajes OWNER TO admin;

--
-- Name: personajes_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.personajes_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personajes_seq OWNER TO admin;

--
-- Name: plan_rodaje_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.plan_rodaje_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.plan_rodaje_seq OWNER TO admin;

--
-- Name: plan_rodaje; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.plan_rodaje (
    id_rodaje text DEFAULT ('rod'::text || nextval('public.plan_rodaje_seq'::regclass)) NOT NULL,
    version character varying(50) NOT NULL,
    semana_grabacion integer,
    dia_rodaje integer,
    hora_inicio time without time zone,
    hora_fin time without time zone,
    location character varying(200),
    notas text,
    activo boolean DEFAULT true
);


ALTER TABLE public.plan_rodaje OWNER TO admin;

--
-- Name: project_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.project_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.project_seq OWNER TO admin;

--
-- Name: projects; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.projects (
    id_project character varying(20) DEFAULT public.generar_id_project() NOT NULL,
    project_name character varying(45) NOT NULL,
    formato_de_produccion public.formatos NOT NULL,
    genero public.generos,
    sinopsis text,
    director character varying NOT NULL,
    id_client integer
);


ALTER TABLE public.projects OWNER TO admin;

--
-- Name: rol_has_permisos; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.rol_has_permisos (
    rol_idrol integer NOT NULL,
    permisos_idpermiso integer NOT NULL
);


ALTER TABLE public.rol_has_permisos OWNER TO admin;

--
-- Name: rol_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.rol_seq
    START WITH 1001
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rol_seq OWNER TO admin;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.roles (
    id_rol integer DEFAULT nextval('public.rol_seq'::regclass) NOT NULL,
    nombre character varying(45) NOT NULL,
    nivel_jerarquia public.jerarquias_rol NOT NULL,
    descripcion text NOT NULL,
    activo boolean DEFAULT true
);


ALTER TABLE public.roles OWNER TO admin;

--
-- Name: user_projects; Type: TABLE; Schema: public; Owner: carlos.yaya
--

CREATE TABLE public.user_projects (
    id integer NOT NULL,
    id_user integer NOT NULL,
    id_project character varying NOT NULL,
    id_rol integer DEFAULT 1005 NOT NULL,
    fecha_vinculacion timestamp without time zone DEFAULT now()
);


ALTER TABLE public.user_projects OWNER TO "carlos.yaya";

--
-- Name: user_projects_id_seq; Type: SEQUENCE; Schema: public; Owner: carlos.yaya
--

CREATE SEQUENCE public.user_projects_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_projects_id_seq OWNER TO "carlos.yaya";

--
-- Name: user_projects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: carlos.yaya
--

ALTER SEQUENCE public.user_projects_id_seq OWNED BY public.user_projects.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.users (
    id_user bigint NOT NULL,
    nombre character varying(255) NOT NULL,
    apellido character varying(255) NOT NULL,
    identificacion public.tipo_documento NOT NULL,
    id_identificacion text NOT NULL,
    mail character varying(255) NOT NULL,
    msisdn text NOT NULL,
    direccion text,
    fecha_de_nacimiento date,
    estado character varying(255) NOT NULL,
    fecha_de_creacion timestamp with time zone NOT NULL,
    ultimo_acceso timestamp with time zone NOT NULL,
    contrasena character varying(255) NOT NULL,
    id_departamento character varying(255),
    id_project text,
    id_rol bigint
);


ALTER TABLE public.users OWNER TO admin;

--
-- Name: users_id_user_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE public.users_id_user_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_user_seq OWNER TO admin;

--
-- Name: users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE public.users_id_user_seq OWNED BY public.users.id_user;


--
-- Name: clients id_cliente; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.clients ALTER COLUMN id_cliente SET DEFAULT nextval('public.clients_id_cliente_seq'::regclass);


--
-- Name: guiones id_guion; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.guiones ALTER COLUMN id_guion SET DEFAULT nextval('public.guiones_id_guion_seq'::regclass);


--
-- Name: user_projects id; Type: DEFAULT; Schema: public; Owner: carlos.yaya
--

ALTER TABLE ONLY public.user_projects ALTER COLUMN id SET DEFAULT nextval('public.user_projects_id_seq'::regclass);


--
-- Name: users id_user; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users ALTER COLUMN id_user SET DEFAULT nextval('public.users_id_user_seq'::regclass);


--
-- Data for Name: actors; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.actors (id_actor, nombre, apellido, genero, fecha_de_nacimiento, talla_zapatos, ancho_espalda, pecho, cintura, cadera, largo_manga, largo_pierna, talla_anillo, contorno_cabeza, contorno_cuello, color_cabello, textura_cabello, tipo_piel, color_ojos, alergias, habilidades_especiales, restricciones, comentarios_adicionales, nacionalidad, doble_riesgo, id_personaje) FROM stdin;
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.clients (id_cliente, document, razon_social, representante_legal, email, address, telephone, number_cellphone, id_document) FROM stdin;
10001	NIT	Banco Mundo Mujer	Pedro Gomez	pedro.gomez@bancomundomujer.com.co	Calle 26 # 80-25	\N	3203451111	\N
10002	NIT	Banco coopcentral	Maria Eugenia Velazquez	mariae.velazquez@coopcentral.com	calle 25 #77-90	\N	320158997	\N
10003	NIT	Banco Davivienda	Mateo Aristizabal	maristizabal@davivienda.com.co	calle 7 #25-85	\N	3236987454	\N
10004	NIT	Banco Popular	Adriana Velazques	adrianaj.velazquez@popular.com	carrera #52-20	\N	3120568778	\N
10005	CC	Productora Epicteto	Diego Andrae	diego.andrea123@gmail.com	dig 16b # 108-23	\N	3112658747	\N
10006	NIT	Banco Falabella	Andrea Romero	andrea.romerov@falabella.com	calle 53 #24-20	\N	3236998740	\N
10007	CE	General Motos Financial	Marcos Rincon	marcosrincon@generalmotors.com	Calle 19 #120-12	\N	3208978787	\N
10008	CC	Pruebas	Javier Gomez	javier.gomez@raccord.com	calle 16 #140-20	\N	3112598978	\N
10009	PA	Mi Banco	Jair Andres Bernal	jairbernal@mibanco.com	calle 100 #93-50	\N	3014699798	\N
10010	NIT	Alter Ego	Pedro Alberto Valencia	pedro.valencia@raccord.com	Calle 30 #50-80	0	3202210596	123SAD
10013	CC	Mi Empresa SAS	Carlos Yaya	carlos.yaya@outlook.com	Calle 100 #10-20, Bogotá	6011234567	3024699797	123456789
10016	CC	Carlos Yaya	Carlos Javier Yaya Gomez	carlos.yaya.111@gmail.com	Calle 16 #99-72		3024699797	1002415392
10025	CC	Cine	Freddy Ardila	freddycardila@gmail.com	Calle 16F #99-72	3213213214	3213213214	12345678
\.


--
-- Data for Name: departamentos; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.departamentos (id_departamento, nombre, ubicacion) FROM stdin;
area01	produccion	Bogotá
area02	direccion	basecamp
area03	locacion	basecamp
area04	coordinacion	basecamp
area05	camara	basecamp
area06	luces	basecamp
area07	grip	basecamp
area08	electricicos	basecamp
area09	sonido	basecamp
area10	arte	basecamp
area11	utileria	basecamp
area12	construccion	basecamp
area13	vesturio	basecamp
area14	maquillaje	basecamp
area15	pelo	basecamp
area16	dobles de accion	basecamp
area17	efectos especiales	basecamp
area18	efectos visuales	basecamp
area19	post produccion	Bogotá
area20	adicionales	basecamp
area21	legal	basecamp
area22	contabilidad	Bogotá
area23	administrativo	Bogotá
area24	casting	basecamp
area25	coordinacion de extras	basecamp
area26	transporte	basecamp
area27	seguridad y salud en el trabajo	basecamp
area28	sostenibilidad	basecamp
area29	catering	basecamp
area30	vehiculos en escenas	basecamp
area31	prosteticos	basecamp
area32	pintura escenica	basecamp
area33	ambientacion de arte	basecamp
area34	ambientacion de vesturio	basecamp
area35	decoracion	basecamp
area36	escultura	basecamp
area37	costura	basecamp
area38	diseñador de produccion	basecamp
area39	carpinteria	basecamp
area40	animales en escenas	basecamp
area41	ornamentación	basecamp
area42	armas	basecamp
\.


--
-- Data for Name: desgloses; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.desgloses (id_desglose, version, semana_grabacion, dia_rodaje, hora_inicio, hora_fin, location, requerimientos, activo) FROM stdin;
\.


--
-- Data for Name: escenas; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.escenas (id_escena, numero_de_escena, encabezado, descripcion, id_guion, modo_vista, momento_dia, ciudad, pagina, fecha_de_grabacion, dia_dramatico, id_rodaje, id_desglose) FROM stdin;
esc001	esc1	REDACCIÓN EL ESPECTADOR	Julián arranca la hoja de la máquina, la dobla con precisión quirúrgica y se pone su gabardina oscura.	2	int	dia	\N	\N	\N	1	\N	\N
esc002	esc2	PLAZA DE BOLÍVAR	Una marea de ruanas, sombreros y personas vestidas de traje rodean el cordón policial	2	ext	dia	\N	\N	\N	1	\N	\N
esc003	esc3	INT-AUTO	Una bala atraviesa el parabrisas. El MINISTRO (DOBLE DE RIESGO) es proyectado violentamente hacia atrás, su cuerpo colapsa contra el cuero del asiento mientras la sangre salpica el vidrio posterior.	2	ext	dia	\N	\N	\N	1	\N	\N
esc004	esc4	CARRERA SÉPTIMA / CALLES DEL CENTRO	Un Jeep Willys de la policía sale en persecución del Mercedes gris.	2	ext	dia	\N	\N	\N	1	\N	\N
esc005	esc5	APARTAMENTO DE JULIÁN	Un Jeep Willys de la policía sale en persecución del Mercedes gris.,Elena saca una tira de negativos del fijador. Gris Julián fuma, sentado en el borde de la bañera.	2	int	noche	\N	\N	\N	1	\N	\N
esc006	esc6	REDACCIÓN ESPECTADOR	Julián camina hacia el escritorio de su editor. El peso de la carpeta bajo su brazo parece de plomo. Pasa frente a Elena, quien finge revisar unos contactos.	2	int	dia	\N	\N	\N	2	\N	\N
esc007	esc7	CALLE DE LA CANDELARIA	el Mercedes gris de la persecución está estacionado al final de la calle	2	ext	atardecer	\N	\N	\N	2	\N	\N
\.


--
-- Data for Name: escenas_personajes; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.escenas_personajes (id_escena, id_personaje) FROM stdin;
\.


--
-- Data for Name: guiones; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.guiones (id_guion, numero_de_version, fecha_de_emision, estado, archivo, nombre, descripcion, id_project) FROM stdin;
1	V.0	2026-03-16	Archivado	https://docs.google.com/document/d/1kjljJBa1twUcqWfE6xr0LyqAovkf6uEHOB3sF0XCW9s/edit?tab=t.0	El silencio de la niebla	primer guión	proj0001
2	V.1	2026-03-24	Aprobado	https://docs.google.com/document/d/1kjljJBa1twUcqWfE6xr0LyqAovkf6uEHOB3sF0XCW9s/edit?tab=t.0	El silencio de la niebla	ampliacion de escenas por la muerte del primer ministro	proj0001
\.


--
-- Data for Name: permisos; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.permisos (id_permiso, codigo, nombre, modulo, descripcion, activo) FROM stdin;
2001	usuarios.create	Crear usuarios	Usuarios	Crear nuevos usuarios	t
2002	usuarios.read	Ver usuarios	Usuarios	Consultar usuarios	t
2003	usuarios.update	Editar usuarios	Usuarios	Modificar usuarios	t
2004	usuarios.delete	Eliminar usuarios	Usuarios	Eliminar usuarios	t
2005	proyectos.create	Crear proyectos	Proyectos	Crear nuevos proyectos	t
2006	proyectos.read	Ver proyectos	Proyectos	Consultar proyectos	t
2007	proyectos.update	Editar proyectos	Proyectos	Modificar proyectos	t
2008	proyectos.delete	Eliminar proyectos	Proyectos	Eliminar proyectos	t
2009	guiones.create	Crear guiones	Guiones	Subir guiones	t
2010	guiones.read	Ver guiones	Guiones	Consultar guiones	t
2011	guiones.update	Editar guiones	Guiones	Modificar guiones	t
2012	guiones.delete	Eliminar guiones	Guiones	Eliminar guiones	t
2013	escenas.create	Crear escenas	Escenas	Crear nuevas escenas	t
2014	escenas.read	Ver escenas	Escenas	Consultar escenas	t
2015	escenas.update	Editar escenas	Escenas	Modificar escenas	t
2016	escenas.delete	Eliminar escenas	Escenas	Eliminar escenas	t
2017	personajes.create	Crear personajes	Personajes	Crear nuevos personajes	t
2018	personajes.read	Ver personajes	Personajes	Consultar personajes	t
2019	personajes.update	Editar personajes	Personajes	Modificar personajes	t
2020	personajes.delete	Eliminar personajes	Personajes	Eliminar personajes	t
2021	actores.create	Crear actores	Actores	Registrar nuevos actores	t
2022	actores.read	Ver actores	Actores	Consultar actores	t
2023	actores.update	Editar actores	Actores	Modificar actores	t
2024	actores.delete	Eliminar actores	Actores	Eliminar actores	t
\.


--
-- Data for Name: personajes; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.personajes (id_personaje, nombre, edad, codigo_personaje) FROM stdin;
\.


--
-- Data for Name: plan_rodaje; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.plan_rodaje (id_rodaje, version, semana_grabacion, dia_rodaje, hora_inicio, hora_fin, location, notas, activo) FROM stdin;
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.projects (id_project, project_name, formato_de_produccion, genero, sinopsis, director, id_client) FROM stdin;
proj0001	El silencio de la niebla	largometraje	crimen	Todo ocurre en la ciudad de Bogota, donde es asesinado el primer ministro	Oscar mesa	10008
proj0002	Pruebas	serie	animacion	pruebas de sofware	Carlos Yaya	10016
proj0003	Pruebas 2	largometraje	video	Segunda	Carlos Yaya	10016
proj0004	Cien años de Daniel	pelicula	fantasia	Un anciano nacido en un pueblo Boyacense, decide emigrar a una ciudad desconocida.	Oscar Mesa	10016
proj0005	Prueba Docente	serie	documental	Vamos a correr	Fredy Ardila	10025
\.


--
-- Data for Name: rol_has_permisos; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.rol_has_permisos (rol_idrol, permisos_idpermiso) FROM stdin;
1001	2001
1001	2002
1001	2003
1001	2004
1001	2005
1001	2006
1001	2007
1001	2008
1001	2009
1001	2010
1001	2011
1001	2012
1001	2013
1001	2014
1001	2015
1001	2016
1001	2017
1001	2018
1001	2019
1001	2020
1001	2021
1001	2022
1001	2023
1001	2024
1002	2001
1002	2002
1002	2003
1002	2004
1002	2005
1002	2006
1002	2007
1002	2008
1002	2009
1002	2010
1002	2011
1002	2012
1002	2013
1002	2014
1002	2015
1002	2016
1002	2017
1002	2018
1002	2019
1002	2020
1002	2021
1002	2022
1002	2023
1002	2024
1003	2001
1003	2002
1003	2003
1003	2004
1003	2006
1003	2007
1003	2010
1003	2011
1003	2014
1003	2015
1003	2017
1003	2018
1003	2019
1003	2020
1003	2021
1003	2022
1003	2023
1003	2024
1004	2001
1004	2002
1004	2005
1004	2006
1004	2009
1004	2010
1004	2013
1004	2014
1004	2017
1004	2018
1004	2021
1004	2022
1005	2002
1005	2006
1005	2010
1005	2014
1005	2018
1005	2022
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.roles (id_rol, nombre, nivel_jerarquia, descripcion, activo) FROM stdin;
1001	Administrador	productora	Control total del sistema	t
1002	Director	direccion	Aprueba y supervisa producción	t
1003	Jefe de Departamento	alto	Gestiona su departamento	t
1004	Onset	medio	Sube y consulta información en producción	t
1005	Usuario	bajo	Solo consulta información	t
\.


--
-- Data for Name: user_projects; Type: TABLE DATA; Schema: public; Owner: carlos.yaya
--

COPY public.user_projects (id, id_user, id_project, id_rol, fecha_vinculacion) FROM stdin;
1	3082	proj0001	1001	2026-03-25 16:20:53.997254
2	3083	proj0001	1002	2026-03-25 16:20:53.997254
3	3084	proj0001	1002	2026-03-25 16:20:53.997254
4	3085	proj0001	1003	2026-03-25 16:20:53.997254
5	3086	proj0001	1003	2026-03-25 16:20:53.997254
6	3087	proj0001	1003	2026-03-25 16:20:53.997254
7	3088	proj0001	1003	2026-03-25 16:20:53.997254
8	3089	proj0001	1003	2026-03-25 16:20:53.997254
9	3090	proj0001	1005	2026-03-25 16:20:53.997254
10	3091	proj0001	1005	2026-03-25 16:20:53.997254
11	3092	proj0001	1005	2026-03-25 16:20:53.997254
12	3093	proj0001	1005	2026-03-25 16:20:53.997254
13	3094	proj0001	1005	2026-03-25 16:20:53.997254
14	3095	proj0001	1005	2026-03-25 16:20:53.997254
15	3096	proj0001	1005	2026-03-25 16:20:53.997254
16	3097	proj0001	1005	2026-03-25 16:20:53.997254
17	3098	proj0001	1005	2026-03-25 16:20:53.997254
18	3100	proj0001	1005	2026-03-25 16:20:53.997254
19	3106	proj0003	1001	2026-06-16 06:59:51.951968
20	3107	proj0003	1005	2026-06-17 22:04:47.143399
21	3106	proj0004	1001	2026-06-19 02:25:54.162037
22	3108	proj0004	1005	2026-06-25 02:04:23.276244
23	3109	proj0004	1005	2026-06-25 02:04:23.276244
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.users (id_user, nombre, apellido, identificacion, id_identificacion, mail, msisdn, direccion, fecha_de_nacimiento, estado, fecha_de_creacion, ultimo_acceso, contrasena, id_departamento, id_project, id_rol) FROM stdin;
3082	Ana	Gómez	CC	23456789	ana.gomez@raccord.com	3112345678	Carrera 15 #93-40, Bogotá	1990-07-22	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	admin123	area01	proj0001	1001
3083	oscar	mesa	CC	34567890	osacar.mesa@raccord.com	3123456789	Av. El Dorado #68-50, Bogotá	1978-11-05	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	dir123	area02	proj0001	1002
3084	María	Pérez	CC	45678901	maria.perez@raccord.com	3134567890	Calle 100 #19-61, Bogotá	1982-04-18	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	dir123	area02	proj0001	1002
3085	Jorge	Martínez	CC	56789012	jorge.martinez@raccord.com	3145678901	Carrera 7 #32-16, Bogotá	1988-09-30	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	jefe123	area03	proj0001	1003
3086	Laura	Sánchez	CC	67890123	laura.sanchez@raccord.com	3156789012	Calle 53 #24-10, Bogotá	1992-01-14	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	jefe123	area35	proj0001	1003
3087	Andrés	Torres	CC	78901234	andres.torres@raccord.com	3167890123	Carrera 30 #45-60, Bogotá	1986-06-25	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	jefe123	area13	proj0001	1003
3088	Valentina	López	CC	89012345	valentina.lopez@raccord.com	3178901234	Calle 127 #53-75, Bogotá	1994-12-08	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	jefe123	area24	proj0001	1003
3089	Ricardo	Castro	CC	90123456	ricardo.castro@raccord.com	3189012345	Av. Suba #114-60, Bogotá	1980-08-19	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	jefe123	area41	proj0001	1003
3090	Camila	Vargas	CC	01234567	camila.vargas@raccord.com	3190123456	Calle 45 #26-85, Bogotá	1995-03-27	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	onset123	area09	proj0001	1005
3091	Diego	Herrera	CC	11223344	diego.herrera@raccord.com	3201234567	Carrera 50 #20-30, Medellín	1991-10-11	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	onset123	area03	proj0001	1005
3092	Sofía	Moreno	CC	22334455	sofia.moreno@raccord.com	3212345678	Calle 10 #4-35, Cali	1993-05-16	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	onset123	area12	proj0001	1005
3093	Felipe	Rojas	CC	33445566	felipe.rojas@raccord.com	3223456789	Av. Américas #35-40, Bogotá	1989-02-28	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	onset123	area41	proj0001	1005
3094	Isabella	Díaz	CC	44556677	isabella.diaz@raccord.com	3234567890	Carrera 68 #22-55, Bogotá	1996-07-04	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	onset123	area24	proj0001	1005
3095	Sebastián	Ruiz	CC	55667788	sebastian.ruiz@raccord.com	3245678901	Calle 72 #10-34, Bogotá	1997-11-20	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	user123	area03	proj0001	1005
3096	Daniela	Flores	CC	66778899	daniela.flores@raccord.com	3256789012	Carrera 11 #93-52, Bogotá	1998-04-09	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	user123	area09	proj0001	1005
3097	Mateo	Reyes	CC	77889900	mateo.reyes@raccord.com	3267890123	Calle 134 #55-20, Bogotá	1999-08-15	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	user123	area13	proj0001	1005
3098	Valeria	Cruz	CC	88990011	valeria.cruz@raccord.com	3278901234	Av. Boyacá #63-40, Bogotá	1996-01-30	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	user123	area12	proj0001	1005
3100	Paula	Guerrero	CC	10111213	paula.guerrero@raccord.com	3290123456	Calle 26 #29-60, Bogotá	1997-09-23	activo	2026-03-25 21:20:53.997254+00	2026-03-25 21:20:53.997254+00	user123	area42	proj0001	1005
3109	Camilo	Nieto	CC	1014858974	icamilops543@gmail.com	3223751228	Calle 16 #99-72	2026-06-24	pendiente	2026-06-24 21:04:26.283676+00	2026-06-25 02:07:39.670915+00	$2b$12$cmMdQnw/YlkdKzMCqo4H7ePSpsdCKsDjEjAPzNFcVFR5yudg1ZV3W	\N	\N	1005
3107	Javier	Gomez yaya	CC	1002415391	carlos.yaya@outlook.com	3024699797	Calle 16F #99-72	2026-06-17	pendiente	2026-06-17 17:04:47.148469+00	2026-06-25 00:14:28.064203+00	$2b$12$IkEgghZCfTDJw0Bd12wjHuB2NNHvFZy31MkZIocF3rNSMp7zUiD3a	\N	\N	1005
3106	Carlos Javier	Yaya Gomez	CC	1002415392	carlos.yaya.111@gmail.com	3024699797	Calle 16 #99-72	2026-06-16	activo	2026-06-16 11:59:51.951968+00	2026-06-25 02:21:48.260382+00	$2b$12$un3B/Iyzg3RDtyR8LPEOV.jwiLY.uCJwtCL6pSLAgu1n6spRm5HKC	\N	proj0003	1001
3108	Juan	Cuevas	CC	1013113684	cr.juanfe06@gmail.com	3219986037A	Calle 33 #7-36	2006-11-25	pendiente	2026-06-24 21:04:23.2795+00	2026-06-25 02:22:48.905058+00	$2b$12$Sc7jRZF/fAKLX4HE0cdAouZ9UWvy8DwkGWR9Iyd0aLQV9oFsNTTN.	\N	\N	1005
\.


--
-- Name: actor_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.actor_seq', 1, false);


--
-- Name: clients_id_cliente_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.clients_id_cliente_seq', 10025, true);


--
-- Name: departamento_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.departamento_seq', 42, true);


--
-- Name: desglose_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.desglose_seq', 1, false);


--
-- Name: escena_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.escena_seq', 7, true);


--
-- Name: guiones_id_guion_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.guiones_id_guion_seq', 2, true);


--
-- Name: permiso_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.permiso_seq', 2024, true);


--
-- Name: personajes_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.personajes_seq', 1, false);


--
-- Name: plan_rodaje_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.plan_rodaje_seq', 1, false);


--
-- Name: project_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.project_seq', 1, false);


--
-- Name: rol_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.rol_seq', 1005, true);


--
-- Name: user_projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: carlos.yaya
--

SELECT pg_catalog.setval('public.user_projects_id_seq', 24, true);


--
-- Name: users_id_user_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('public.users_id_user_seq', 3110, true);


--
-- Name: actors actors_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.actors
    ADD CONSTRAINT actors_pkey PRIMARY KEY (id_actor);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id_cliente);


--
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id_departamento);


--
-- Name: desgloses desgloses_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.desgloses
    ADD CONSTRAINT desgloses_pkey PRIMARY KEY (id_desglose);


--
-- Name: escenas_personajes escenas_personajes_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.escenas_personajes
    ADD CONSTRAINT escenas_personajes_pkey PRIMARY KEY (id_escena, id_personaje);


--
-- Name: escenas escenas_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.escenas
    ADD CONSTRAINT escenas_pkey PRIMARY KEY (id_escena);


--
-- Name: guiones guiones_numero_de_version_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.guiones
    ADD CONSTRAINT guiones_numero_de_version_key UNIQUE (numero_de_version);


--
-- Name: guiones guiones_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.guiones
    ADD CONSTRAINT guiones_pkey PRIMARY KEY (id_guion);


--
-- Name: permisos permisos_codigo_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_codigo_key UNIQUE (codigo);


--
-- Name: permisos permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.permisos
    ADD CONSTRAINT permisos_pkey PRIMARY KEY (id_permiso);


--
-- Name: personajes personajes_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.personajes
    ADD CONSTRAINT personajes_pkey PRIMARY KEY (id_personaje);


--
-- Name: plan_rodaje plan_rodaje_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.plan_rodaje
    ADD CONSTRAINT plan_rodaje_pkey PRIMARY KEY (id_rodaje);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id_project);


--
-- Name: rol_has_permisos rol_has_permisos_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rol_has_permisos
    ADD CONSTRAINT rol_has_permisos_pkey PRIMARY KEY (rol_idrol, permisos_idpermiso);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id_rol);


--
-- Name: user_projects user_projects_id_user_id_project_key; Type: CONSTRAINT; Schema: public; Owner: carlos.yaya
--

ALTER TABLE ONLY public.user_projects
    ADD CONSTRAINT user_projects_id_user_id_project_key UNIQUE (id_user, id_project);


--
-- Name: user_projects user_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: carlos.yaya
--

ALTER TABLE ONLY public.user_projects
    ADD CONSTRAINT user_projects_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- Name: idx_permisos_codigo; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_permisos_codigo ON public.permisos USING btree (codigo);


--
-- Name: idx_permisos_modulo; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_permisos_modulo ON public.permisos USING btree (modulo);


--
-- Name: actors trg_id_actor; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_id_actor BEFORE INSERT ON public.actors FOR EACH ROW EXECUTE FUNCTION public.gen_id_actor();


--
-- Name: departamentos trg_id_departamento; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_id_departamento BEFORE INSERT ON public.departamentos FOR EACH ROW EXECUTE FUNCTION public.gen_id_departamento();


--
-- Name: escenas trg_id_escena; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_id_escena BEFORE INSERT ON public.escenas FOR EACH ROW EXECUTE FUNCTION public.gen_id_escena();


--
-- Name: personajes trg_id_personaje; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER trg_id_personaje BEFORE INSERT ON public.personajes FOR EACH ROW EXECUTE FUNCTION public.gen_id_personaje();


--
-- Name: actors fk_actor_personaje; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.actors
    ADD CONSTRAINT fk_actor_personaje FOREIGN KEY (id_personaje) REFERENCES public.personajes(id_personaje) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: escenas fk_escenas_desglose; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.escenas
    ADD CONSTRAINT fk_escenas_desglose FOREIGN KEY (id_desglose) REFERENCES public.desgloses(id_desglose) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: escenas fk_escenas_guion; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.escenas
    ADD CONSTRAINT fk_escenas_guion FOREIGN KEY (id_guion) REFERENCES public.guiones(id_guion) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: escenas_personajes fk_escenas_personajes_escena; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.escenas_personajes
    ADD CONSTRAINT fk_escenas_personajes_escena FOREIGN KEY (id_escena) REFERENCES public.escenas(id_escena) ON DELETE CASCADE;


--
-- Name: escenas_personajes fk_escenas_personajes_personaje; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.escenas_personajes
    ADD CONSTRAINT fk_escenas_personajes_personaje FOREIGN KEY (id_personaje) REFERENCES public.personajes(id_personaje) ON DELETE CASCADE;


--
-- Name: escenas fk_escenas_rodaje; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.escenas
    ADD CONSTRAINT fk_escenas_rodaje FOREIGN KEY (id_rodaje) REFERENCES public.plan_rodaje(id_rodaje) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: guiones fk_guion_project; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.guiones
    ADD CONSTRAINT fk_guion_project FOREIGN KEY (id_project) REFERENCES public.projects(id_project) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: projects fk_project_client; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_project_client FOREIGN KEY (id_client) REFERENCES public.clients(id_cliente) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: rol_has_permisos fk_rol_has_permisos_permisos; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rol_has_permisos
    ADD CONSTRAINT fk_rol_has_permisos_permisos FOREIGN KEY (permisos_idpermiso) REFERENCES public.permisos(id_permiso) ON DELETE CASCADE;


--
-- Name: rol_has_permisos fk_rol_has_permisos_rol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.rol_has_permisos
    ADD CONSTRAINT fk_rol_has_permisos_rol FOREIGN KEY (rol_idrol) REFERENCES public.roles(id_rol) ON DELETE CASCADE;


--
-- Name: users fk_users_departamento; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_departamento FOREIGN KEY (id_departamento) REFERENCES public.departamentos(id_departamento) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users fk_users_project; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_project FOREIGN KEY (id_project) REFERENCES public.projects(id_project) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: users fk_users_rol; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_users_rol FOREIGN KEY (id_rol) REFERENCES public.roles(id_rol) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: user_projects user_projects_id_project_fkey; Type: FK CONSTRAINT; Schema: public; Owner: carlos.yaya
--

ALTER TABLE ONLY public.user_projects
    ADD CONSTRAINT user_projects_id_project_fkey FOREIGN KEY (id_project) REFERENCES public.projects(id_project) ON DELETE CASCADE;


--
-- Name: user_projects user_projects_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: carlos.yaya
--

ALTER TABLE ONLY public.user_projects
    ADD CONSTRAINT user_projects_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id_user) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Lj1AvXA4QETtEgH7URwyV2assKAVRgJPh0uMzPeqHGZdqPU0RTYwOwHrhRKd0op

