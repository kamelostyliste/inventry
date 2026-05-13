-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- PRODUCTS table
CREATE TABLE products (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  sku TEXT UNIQUE NOT NULL,
  stock INTEGER DEFAULT 0,
  image TEXT,
  movements JSONB DEFAULT '[]'::jsonb,
  weight_per_6 NUMERIC(10, 3),
  purchase_price NUMERIC(10, 2),
  sale_price_carton NUMERIC(10, 2),
  sale_price_half_carton NUMERIC(10, 2),
  sale_price_piece NUMERIC(10, 2),
  items_per_carton INTEGER DEFAULT 1,
  alert_threshold INTEGER DEFAULT 5,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- CUSTOMERS table
CREATE TABLE customers (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  name TEXT NOT NULL,
  phone TEXT,
  phone_secondary TEXT,
  state TEXT,
  municipality TEXT,
  code TEXT UNIQUE,
  address TEXT,
  city TEXT,
  notes TEXT,
  history JSONB DEFAULT '[]'::jsonb,
  balance NUMERIC(10, 2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ORDERS table
CREATE TABLE orders (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_no TEXT UNIQUE NOT NULL,
  customer_id UUID REFERENCES customers(id),
  customer_name TEXT,
  customer_phone TEXT,
  customer_phone2 TEXT,
  type TEXT CHECK (type IN ('delivery', 'exchange')),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')),
  payment_status TEXT DEFAULT 'unpaid',
  delivery_location TEXT CHECK (delivery_location IN ('home', 'office')),
  delivery_address TEXT,
  delivery_wilaya TEXT,
  delivery_commune TEXT,
  station_code TEXT,
  delivery_fees NUMERIC(10, 2) DEFAULT 0,
  free_delivery BOOLEAN DEFAULT FALSE,
  product_price NUMERIC(10, 2) DEFAULT 0,
  items_total NUMERIC(10, 2) DEFAULT 0,
  discount NUMERIC(10, 2) DEFAULT 0,
  package_content TEXT,
  total NUMERIC(10, 2) DEFAULT 0,
  weight NUMERIC(10, 2),
  date TEXT,
  notes TEXT,
  items JSONB DEFAULT '[]'::jsonb,
  adjustments JSONB DEFAULT '[]'::jsonb,
  tracking_code TEXT,
  tracking_status TEXT,
  stock BOOLEAN DEFAULT FALSE,
  quantite INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- ORDER_ITEMS table
CREATE TABLE order_items (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id),
  quantity INTEGER NOT NULL,
  price_at_sale NUMERIC(10, 2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- STOCK_HISTORY table
CREATE TABLE stock_history (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  change_amount INTEGER NOT NULL,
  type TEXT CHECK (type IN ('addition', 'sale', 'exchange', 'adjustment')),
  reference_id UUID, -- Can be order_id
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Migration: add missing columns for existing databases
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_phone TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS customer_phone2 TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_address TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_wilaya TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS delivery_commune TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS station_code TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS product_price NUMERIC(10, 2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS items_total NUMERIC(10, 2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount NUMERIC(10, 2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS package_content TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tracking_code TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS tracking_status TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS stock BOOLEAN DEFAULT FALSE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS quantite INTEGER DEFAULT 0;

-- Disable RLS (single-user/small-team app — enable later if needed)
ALTER TABLE products DISABLE ROW LEVEL SECURITY;
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE order_items DISABLE ROW LEVEL SECURITY;
ALTER TABLE stock_history DISABLE ROW LEVEL SECURITY;

-- Storage policies for product-images bucket
CREATE POLICY "Allow public uploads"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'product-images');
