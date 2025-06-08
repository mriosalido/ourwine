```sql
-- 1. Crear la tabla de vinos (sin user_id)
CREATE TABLE wines (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  year INT NOT NULL,
  name TEXT NOT NULL,
  winery TEXT NOT NULL,
  kind TEXT NOT NULL,
  value TEXT NOT NULL,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Habilitar Row Level Security (es una buena práctica tenerla siempre activa)
ALTER TABLE wines ENABLE ROW LEVEL SECURITY;

-- 3. Crear una política pública temporal
-- ESTO PERMITE A CUALQUIERA LEER Y ESCRIBIR EN LA TABLA.
-- Lo cambiaremos en la siguiente iteración para que sea seguro.
CREATE POLICY "Public access for now"
ON wines FOR ALL
USING (true)
WITH CHECK (true);
````

```sql
-- 1. Crear la tabla para las fotos de los vinos
CREATE TABLE wine_photos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  wine_id UUID REFERENCES wines(id) ON DELETE CASCADE NOT NULL,
  storage_path TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- La cláusula "ON DELETE CASCADE" es importante: si borras un vino,
-- todas sus fotos asociadas se borrarán automáticamente.

-- 2. Habilitar Row Level Security
ALTER TABLE wine_photos ENABLE ROW LEVEL SECURITY;

-- 3. Crear una política pública temporal para las fotos
-- (para que coincida con la de la tabla de vinos)
CREATE POLICY "Public access for photos for now"
ON wine_photos FOR ALL
USING (true)
WITH CHECK (true);
```