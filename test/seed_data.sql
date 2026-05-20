-- =========================================================================
-- SCRIPT DE INICIALIZACIÓN Y DESACTIVACIÓN DE RLS (SEGURIDAD) - UNAJ MATRICULAS
-- Ejecuta este script en el "SQL Editor" de tu Dashboard de Supabase.
-- =========================================================================

-- 1. DESACTIVAR ROW LEVEL SECURITY (RLS) EN TODAS LAS TABLAS
-- Supabase por defecto activa RLS, lo que hace que las tablas parezcan vacías ([])
-- para el cliente Flutter a menos que existan políticas. Desactivarlo resuelve esto al 100%.
ALTER TABLE public.roles DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.facultades DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.carreras DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.semestres DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.configuracion_academica DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cursos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.curso_carrera DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.estudiantes DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.pagos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalle_matricula DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.matriculas DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.prerequisitos DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.historial_academico DISABLE ROW LEVEL SECURITY;

-- 2. INSERTAR ROLES BÁSICOS (ADMIN y ESTUDIANTE)
INSERT INTO public.roles (id, nombre, descripcion)
OVERRIDING SYSTEM VALUE
VALUES 
  (1, 'ADMIN', 'Administrador General del Sistema académico'),
  (2, 'ESTUDIANTE', 'Estudiante de pregrado regular')
ON CONFLICT (id) DO UPDATE 
SET nombre = EXCLUDED.nombre, descripcion = EXCLUDED.descripcion;

-- 3. INSERTAR FACULTADES (FIIN)
INSERT INTO public.facultades (id, codigo, nombre, siglas)
OVERRIDING SYSTEM VALUE
VALUES 
  (1, 'FIIN', 'FACULTAD DE INGENIERIAS E INDUSTRIAS', 'FIIN')
ON CONFLICT (id) DO UPDATE 
SET codigo = EXCLUDED.codigo, nombre = EXCLUDED.nombre, siglas = EXCLUDED.siglas;

-- 4. INSERTAR CARRERAS (INGENIERÍA DE SISTEMAS)
INSERT INTO public.carreras (id, facultad_id, codigo_carrera, nombre, total_creditos)
OVERRIDING SYSTEM VALUE
VALUES 
  (1, 1, 'INF', 'INGENIERIA DE SISTEMAS', 220)
ON CONFLICT (id) DO UPDATE 
SET facultad_id = EXCLUDED.facultad_id, codigo_carrera = EXCLUDED.codigo_carrera, nombre = EXCLUDED.nombre, total_creditos = EXCLUDED.total_creditos;

-- 5. INSERTAR SEMESTRES (Semestre académico activo)
INSERT INTO public.semestres (id, nombre, fecha_inicio, fecha_fin, activo)
OVERRIDING SYSTEM VALUE
VALUES 
  (1, '2026-I', '2026-04-01', '2026-08-31', true)
ON CONFLICT (id) DO UPDATE 
SET nombre = EXCLUDED.nombre, fecha_inicio = EXCLUDED.fecha_inicio, fecha_fin = EXCLUDED.fecha_fin, activo = EXCLUDED.activo;

-- 6. INSERTAR CONFIGURACIÓN ACADÉMICA
INSERT INTO public.configuracion_academica (id, carrera_id, nota_minima, max_creditos_regular, max_creditos_observado, max_veces_desaprobado)
OVERRIDING SYSTEM VALUE
VALUES 
  (1, 1, 11, 22, 12, 3)
ON CONFLICT (id) DO UPDATE 
SET carrera_id = EXCLUDED.carrera_id, nota_minima = EXCLUDED.nota_minima, max_creditos_regular = EXCLUDED.max_creditos_regular, max_creditos_observado = EXCLUDED.max_creditos_observado, max_veces_desaprobado = EXCLUDED.max_veces_desaprobado;

-- 7. INSERTAR CURSOS PILOTO DE INGENIERÍA DE SISTEMAS (Para que el módulo de matrículas funcione)
INSERT INTO public.cursos (id, codigo_curso, nombre, creditos, ciclo, tipo_curso, horas_teoria, horas_practica, carrera_principal_id)
OVERRIDING SYSTEM VALUE
VALUES 
  (1, 'INF-101', 'INTRODUCCION A LA INGENIERIA DE SISTEMAS', 4, 1, 'OBLIGATORIO', 3, 2, 1),
  (2, 'INF-201', 'ALGORITMOS Y ESTRUCTURAS DE DATOS', 4, 2, 'OBLIGATORIO', 2, 4, 1),
  (3, 'INF-401', 'BASE DE DATOS I', 4, 4, 'OBLIGATORIO', 2, 4, 1),
  (4, 'INF-501', 'INGENIERIA DE SOFTWARE I', 4, 5, 'OBLIGATORIO', 3, 2, 1),
  (5, 'INF-601', 'REDES Y CONECTIVIDAD', 4, 6, 'OBLIGATORIO', 2, 4, 1),
  (6, 'INF-801', 'INTELIGENCIA ARTIFICIAL', 4, 8, 'OBLIGATORIO', 3, 2, 1)
ON CONFLICT (id) DO UPDATE 
SET codigo_curso = EXCLUDED.codigo_curso, 
    nombre = EXCLUDED.nombre, 
    creditos = EXCLUDED.creditos, 
    ciclo = EXCLUDED.ciclo, 
    tipo_curso = EXCLUDED.tipo_curso, 
    horas_teoria = EXCLUDED.horas_teoria, 
    horas_practica = EXCLUDED.horas_practica, 
    carrera_principal_id = EXCLUDED.carrera_principal_id;

-- Vincular los cursos a la carrera de sistemas (curso_carrera)
INSERT INTO public.curso_carrera (curso_id, carrera_id, estado)
VALUES 
  (1, 1, true),
  (2, 1, true),
  (3, 1, true),
  (4, 1, true),
  (5, 1, true),
  (6, 1, true)
ON CONFLICT DO NOTHING;

-- 8. VINCULAR TU USUARIO DE SUPABASE AUTH CON TU PERFIL ESTUDIANTIL
-- Asegúrate de que el UUID coincida con tu registro de Supabase Auth
INSERT INTO public.usuarios (id, rol_id, dni, nombres, apellido_paterno, apellido_materno, correo, codigo_estudiante)
VALUES (
  '21450006-5246-4132-b43e-02c43a4dca10', -- Tu UUID de Auth
  2, -- Rol: ESTUDIANTE
  '75272636', -- Tu DNI
  'Deivis Bryan', -- Tus Nombres
  'Quispe', -- Tu Apellido Paterno
  'Pacompia', -- Tu Apellido Materno
  '75272636.est@unaj.edu.pe', -- Tu Correo
  '2022107034' -- Tu Código Estudiante
)
ON CONFLICT (id) DO UPDATE 
SET rol_id = EXCLUDED.rol_id,
    dni = EXCLUDED.dni,
    nombres = EXCLUDED.nombres,
    apellido_paterno = EXCLUDED.apellido_paterno,
    apellido_materno = EXCLUDED.apellido_materno,
    correo = EXCLUDED.correo,
    codigo_estudiante = EXCLUDED.codigo_estudiante;

-- 9. CARGAR TU PERFIL EN LA TABLA DE ESTUDIANTES
INSERT INTO public.estudiantes (usuario_id, carrera_id, codigo_estudiante, anio_ingreso, semestre_ingreso, tipo_estudiante, estado_academico, creditos_aprobados)
VALUES (
  '21450006-5246-4132-b43e-02c43a4dca10', -- Tu UUID
  1, -- Carrera: Sistemas (ID 1)
  '2022107034', -- Tu Código Estudiante
  2022, -- Año de ingreso
  1, -- Semestre de ingreso
  'REGULAR',
  'ACTIVO',
  0
)
ON CONFLICT (usuario_id) DO UPDATE
SET carrera_id = EXCLUDED.carrera_id,
    codigo_estudiante = EXCLUDED.codigo_estudiante,
    anio_ingreso = EXCLUDED.anio_ingreso,
    semestre_ingreso = EXCLUDED.semestre_ingreso,
    tipo_estudiante = EXCLUDED.tipo_estudiante,
    estado_academico = EXCLUDED.estado_academico,
    creditos_aprobados = EXCLUDED.creditos_aprobados;
