-- ========================================
-- SQL COMPLETO PARA SISTEMA DE INSPECCIÓN ICA
-- IMPORTANTE: Usar comillas dobles para preservar mayúsculas/minúsculas
-- ========================================

-- Primero eliminar tablas existentes si existen (en minúsculas)
DROP TABLE IF EXISTS inspeccionica_detalles_inspeccion CASCADE;
DROP TABLE IF EXISTS inspeccionica_inspecciones CASCADE;
DROP TABLE IF EXISTS inspeccionica_criterios CASCADE;
DROP TABLE IF EXISTS inspeccionica_usuarios CASCADE;
DROP TABLE IF EXISTS inspeccionica_buses CASCADE;
DROP TABLE IF EXISTS inspeccionica_terminales CASCADE;

-- Tabla de Terminales (CON COMILLAS DOBLES para preservar mayúsculas)
CREATE TABLE "InspeccionICA_terminales" (
    id BIGSERIAL PRIMARY KEY,
    nombre TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Buses
CREATE TABLE "InspeccionICA_buses" (
    ppu TEXT PRIMARY KEY,
    numero_interno TEXT,
    terminal_id BIGINT REFERENCES "InspeccionICA_terminales"(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Usuarios
CREATE TABLE "InspeccionICA_usuarios" (
    id BIGSERIAL PRIMARY KEY,
    nombre_completo TEXT NOT NULL,
    rol TEXT NOT NULL CHECK (rol IN ('Supervisor', 'Cleaner', 'Fiscalizador', 'Registrador', 'Administrador')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Criterios de Inspección
CREATE TABLE "InspeccionICA_criterios" (
    id BIGSERIAL PRIMARY KEY,
    descripcion TEXT NOT NULL,
    numero_condicion INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Inspecciones
CREATE TABLE "InspeccionICA_inspecciones" (
    id BIGSERIAL PRIMARY KEY,
    bus_ppu TEXT NOT NULL REFERENCES "InspeccionICA_buses"(ppu) ON DELETE CASCADE,
    terminal_id BIGINT REFERENCES "InspeccionICA_terminales"(id) ON DELETE SET NULL,
    terminal_inspeccion TEXT,
    nombre_fiscalizador TEXT NOT NULL,
    nombre_registrador TEXT NOT NULL,
    estado_general TEXT NOT NULL CHECK (estado_general IN ('Pendiente', 'En Revisión', 'Solucionada')),
    observaciones_generales TEXT,
    supervisor_asignado_id BIGINT REFERENCES "InspeccionICA_usuarios"(id) ON DELETE SET NULL,
    cleaner_asignado_id BIGINT REFERENCES "InspeccionICA_usuarios"(id) ON DELETE SET NULL,
    fecha_hora_inspeccion TIMESTAMPTZ DEFAULT NOW(),
    fecha_ultima_actualizacion_estado TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Detalles de Inspección
CREATE TABLE "InspeccionICA_detalles_inspeccion" (
    id BIGSERIAL PRIMARY KEY,
    inspeccion_id BIGINT NOT NULL REFERENCES "InspeccionICA_inspecciones"(id) ON DELETE CASCADE,
    criterio_id BIGINT NOT NULL REFERENCES "InspeccionICA_criterios"(id) ON DELETE CASCADE,
    cumple BOOLEAN NOT NULL,
    observacion_criterio TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(inspeccion_id, criterio_id)
);

-- ========================================
-- ÍNDICES PARA OPTIMIZACIÓN
-- ========================================

CREATE INDEX idx_inspecciones_bus_ppu ON "InspeccionICA_inspecciones"(bus_ppu);
CREATE INDEX idx_inspecciones_terminal_id ON "InspeccionICA_inspecciones"(terminal_id);
CREATE INDEX idx_inspecciones_estado_general ON "InspeccionICA_inspecciones"(estado_general);
CREATE INDEX idx_inspecciones_fecha_hora ON "InspeccionICA_inspecciones"(fecha_hora_inspeccion DESC);
CREATE INDEX idx_inspecciones_supervisor ON "InspeccionICA_inspecciones"(supervisor_asignado_id);
CREATE INDEX idx_inspecciones_cleaner ON "InspeccionICA_inspecciones"(cleaner_asignado_id);
CREATE INDEX idx_detalles_inspeccion_id ON "InspeccionICA_detalles_inspeccion"(inspeccion_id);
CREATE INDEX idx_detalles_criterio_id ON "InspeccionICA_detalles_inspeccion"(criterio_id);
CREATE INDEX idx_buses_terminal_id ON "InspeccionICA_buses"(terminal_id);

-- ========================================
-- POLÍTICAS RLS (Row Level Security)
-- ========================================

ALTER TABLE "InspeccionICA_terminales" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "InspeccionICA_buses" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "InspeccionICA_usuarios" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "InspeccionICA_criterios" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "InspeccionICA_inspecciones" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "InspeccionICA_detalles_inspeccion" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura pública terminales" ON "InspeccionICA_terminales" FOR SELECT USING (true);
CREATE POLICY "Permitir lectura pública buses" ON "InspeccionICA_buses" FOR SELECT USING (true);
CREATE POLICY "Permitir lectura pública usuarios" ON "InspeccionICA_usuarios" FOR SELECT USING (true);
CREATE POLICY "Permitir lectura pública criterios" ON "InspeccionICA_criterios" FOR SELECT USING (true);
CREATE POLICY "Permitir lectura pública inspecciones" ON "InspeccionICA_inspecciones" FOR SELECT USING (true);
CREATE POLICY "Permitir lectura pública detalles" ON "InspeccionICA_detalles_inspeccion" FOR SELECT USING (true);

CREATE POLICY "Permitir inserción inspecciones" ON "InspeccionICA_inspecciones" FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir inserción detalles" ON "InspeccionICA_detalles_inspeccion" FOR INSERT WITH CHECK (true);

CREATE POLICY "Permitir actualización inspecciones" ON "InspeccionICA_inspecciones" FOR UPDATE USING (true);
CREATE POLICY "Permitir actualización detalles" ON "InspeccionICA_detalles_inspeccion" FOR UPDATE USING (true);

CREATE POLICY "Permitir eliminación inspecciones" ON "InspeccionICA_inspecciones" FOR DELETE USING (true);
CREATE POLICY "Permitir eliminación detalles" ON "InspeccionICA_detalles_inspeccion" FOR DELETE USING (true);

-- ========================================
-- DATOS DE EJEMPLO (OPCIONAL)
-- ========================================

INSERT INTO "InspeccionICA_terminales" (nombre) VALUES
    ('Terminal San Borja'),
    ('Terminal Pajaritos'),
    ('Terminal Las Rejas'),
    ('Terminal La Cisterna'),
    ('Terminal Maipú')
ON CONFLICT (nombre) DO NOTHING;

INSERT INTO "InspeccionICA_criterios" (descripcion, numero_condicion) VALUES
    ('Estado general del bus', 1),
    ('Limpieza interior', 2),
    ('Limpieza exterior', 3),
    ('Estado de asientos', 4),
    ('Funcionamiento de puertas', 5),
    ('Estado de ventanas', 6),
    ('Sistema de iluminación', 7),
    ('Estado de pasamanos', 8),
    ('Limpieza de baños', 9),
    ('Señalética visible', 10)
ON CONFLICT DO NOTHING;

INSERT INTO "InspeccionICA_usuarios" (nombre_completo, rol) VALUES
    ('Juan Pérez', 'Supervisor'),
    ('María González', 'Supervisor'),
    ('Carlos Rodríguez', 'Cleaner'),
    ('Ana Martínez', 'Cleaner'),
    ('Pedro Sánchez', 'Fiscalizador')
ON CONFLICT DO NOTHING;

-- ========================================
-- COMENTARIOS
-- ========================================

COMMENT ON TABLE "InspeccionICA_terminales" IS 'Catálogo de terminales de buses';
COMMENT ON TABLE "InspeccionICA_buses" IS 'Registro de buses del sistema';
COMMENT ON TABLE "InspeccionICA_usuarios" IS 'Usuarios del sistema (supervisores, cleaners, fiscalizadores)';
COMMENT ON TABLE "InspeccionICA_criterios" IS 'Criterios de inspección predefinidos';
COMMENT ON TABLE "InspeccionICA_inspecciones" IS 'Registro de inspecciones realizadas';
COMMENT ON TABLE "InspeccionICA_detalles_inspeccion" IS 'Detalles de cada criterio evaluado en una inspección';
