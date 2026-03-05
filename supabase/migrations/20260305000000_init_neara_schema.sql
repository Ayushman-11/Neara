-- Neara Supabase Schema Migration
-- Designed for hyperlocal worker connection, escrow payments, and SOS features.

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

----------------------------------------
-- 1. Create Enums
----------------------------------------

CREATE TYPE profile_role AS ENUM ('customer', 'worker');
CREATE TYPE worker_status AS ENUM ('available', 'busy', 'offline');
CREATE TYPE service_urgency AS ENUM ('normal', 'emergency');
CREATE TYPE service_request_status AS ENUM (
  'REQUEST_SENT', 
  'REQUEST_ACCEPTED', 
  'PROPOSAL_SENT', 
  'NEGOTIATION', 
  'ADVANCE_PAID', 
  'WORKER_COMING', 
  'WORKER_ARRIVED', 
  'SERVICE_STARTED', 
  'SERVICE_COMPLETED', 
  'FINAL_PAYMENT_PENDING', 
  'SERVICE_CLOSED'
);
CREATE TYPE proposal_status AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED');
CREATE TYPE payment_type AS ENUM ('ADVANCE', 'FINAL');
CREATE TYPE payment_status AS ENUM ('HELD_IN_ESCROW', 'RELEASED', 'REFUNDED');

----------------------------------------
-- 2. Create Tables
----------------------------------------

-- Service Categories (e.g. Plumber, Electrician)
CREATE TABLE service_categories (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  name text NOT NULL UNIQUE,
  icon_url text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Profiles (Customers and Workers)
CREATE TABLE profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role profile_role NOT NULL,
  full_name text NOT NULL,
  phone_number text UNIQUE,
  location_lat numeric,
  location_lng numeric,
  service_category_id uuid REFERENCES service_categories(id) ON DELETE SET NULL, -- Nullable; mainly for workers
  availability_status worker_status DEFAULT 'offline',
  rating_avg numeric DEFAULT 0.0,
  completed_jobs integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Service Requests
CREATE TABLE service_requests (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  customer_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  worker_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
  category_id uuid NOT NULL REFERENCES service_categories(id),
  problem_description text NOT NULL,
  urgency service_urgency DEFAULT 'normal' NOT NULL,
  status service_request_status DEFAULT 'REQUEST_SENT' NOT NULL,
  location_lat numeric NOT NULL,
  location_lng numeric NOT NULL,
  total_cost numeric,
  advance_paid numeric DEFAULT 0,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Proposals (Worker bids to customer requests)
CREATE TABLE proposals (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_request_id uuid NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  worker_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  inspection_fee numeric DEFAULT 0,
  estimated_cost numeric DEFAULT 0,
  advance_percent integer DEFAULT 0 CHECK (advance_percent >= 0 AND advance_percent <= 100),
  notes text,
  status proposal_status DEFAULT 'PENDING' NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Payments (Advance & Final, including Escrow logic)
CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_request_id uuid NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  payer_id uuid NOT NULL REFERENCES profiles(id),
  payee_id uuid NOT NULL REFERENCES profiles(id),
  amount numeric NOT NULL CHECK (amount > 0),
  type payment_type NOT NULL,
  status payment_status DEFAULT 'HELD_IN_ESCROW' NOT NULL,
  transaction_id text UNIQUE,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
  updated_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Reviews
CREATE TABLE reviews (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  service_request_id uuid NOT NULL REFERENCES service_requests(id),
  reviewer_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  reviewee_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Emergency Contacts
CREATE TABLE emergency_contacts (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  name text NOT NULL,
  phone_number text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


----------------------------------------
-- 3. Row Level Security (RLS)
----------------------------------------
-- These policies provide a baseline of security for the app.

ALTER TABLE service_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE proposals ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE emergency_contacts ENABLE ROW LEVEL SECURITY;

-- Service Categories (Open to read)
CREATE POLICY "Categories are viewable by everyone" ON service_categories FOR SELECT USING (true);

-- Profiles (Open to read so workers can be listed)
CREATE POLICY "Profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- Service Requests (Viewable by the customer or the assigned worker)
CREATE POLICY "Users view own requests" ON service_requests FOR SELECT USING (
  auth.uid() = customer_id OR auth.uid() = worker_id
);
CREATE POLICY "Customers can create requests" ON service_requests FOR INSERT WITH CHECK (auth.uid() = customer_id);
CREATE POLICY "Customers and workers can update" ON service_requests FOR UPDATE USING (
  auth.uid() = customer_id OR auth.uid() = worker_id
);

-- Proposals (Viewable by the worker who created it and the customer of the request)
CREATE POLICY "View relevant proposals" ON proposals FOR SELECT USING (
  auth.uid() = worker_id OR auth.uid() IN (SELECT customer_id FROM service_requests WHERE id = service_request_id)
);
CREATE POLICY "Workers can insert proposals" ON proposals FOR INSERT WITH CHECK (auth.uid() = worker_id);
CREATE POLICY "Participants can update proposals" ON proposals FOR UPDATE USING (
  auth.uid() = worker_id OR auth.uid() IN (SELECT customer_id FROM service_requests WHERE id = service_request_id)
);

-- Payments (Viewable by payer and payee)
CREATE POLICY "Participants view payments" ON payments FOR SELECT USING (
  auth.uid() = payer_id OR auth.uid() = payee_id
);
CREATE POLICY "Payer can create payment record" ON payments FOR INSERT WITH CHECK (auth.uid() = payer_id);
CREATE POLICY "Participants can update payment" ON payments FOR UPDATE USING (
  auth.uid() = payer_id OR auth.uid() = payee_id
);

-- Reviews (Viewable by all)
CREATE POLICY "Reviews viewable by everyone" ON reviews FOR SELECT USING (true);
CREATE POLICY "Users can create reviews" ON reviews FOR INSERT WITH CHECK (auth.uid() = reviewer_id);

-- Emergency Contacts (Only viewable by the user)
CREATE POLICY "Users view own emergency contacts" ON emergency_contacts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users insert own emergency contacts" ON emergency_contacts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users update own emergency contacts" ON emergency_contacts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users delete own emergency contacts" ON emergency_contacts FOR DELETE USING (auth.uid() = user_id);

----------------------------------------
-- 4. Enable Realtime
----------------------------------------
-- Enables realtime updates for these tables (crucial for negotiation and lifecycle states)
ALTER PUBLICATION supabase_realtime ADD TABLE service_requests;
ALTER PUBLICATION supabase_realtime ADD TABLE proposals;
ALTER PUBLICATION supabase_realtime ADD TABLE payments;
