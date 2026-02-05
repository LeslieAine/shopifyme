-- merchant
CREATE TABLE IF NOT EXISTS merchant (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  store_id TEXT UNIQUE,
  sales_channel_id TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT merchant_status_check CHECK (status IN ('pending', 'active'))
);

CREATE UNIQUE INDEX IF NOT EXISTS IDX_merchant_email_unique
  ON merchant (email)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS IDX_merchant_deleted_at
  ON merchant (deleted_at)
  WHERE deleted_at IS NULL;

-- merchant_auth_identity
CREATE TABLE IF NOT EXISTS merchant_auth_identity (
  id TEXT PRIMARY KEY,
  auth_identity_id TEXT NOT NULL UNIQUE,
  merchant_id TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CONSTRAINT merchant_auth_identity_merchant_fk
    FOREIGN KEY (merchant_id)
    REFERENCES merchant(id)
    ON DELETE CASCADE
);

-- merchant_user
CREATE TABLE IF NOT EXISTS merchant_user (
  id TEXT PRIMARY KEY,
  merchant_id TEXT NOT NULL,
  auth_identity_id TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'owner',
  CONSTRAINT merchant_user_merchant_fk
    FOREIGN KEY (merchant_id)
    REFERENCES merchant(id)
    ON DELETE CASCADE
);

-- merchant_categories
CREATE TABLE IF NOT EXISTS merchant_categories (
  id TEXT PRIMARY KEY,
  sales_channel_id TEXT NOT NULL,
  title TEXT NOT NULL,
  handle TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT now(),
  CONSTRAINT merchant_categories_sales_channel_handle_unique
    UNIQUE (sales_channel_id, handle)
);

-- merchant_collections
CREATE TABLE IF NOT EXISTS merchant_collections (
  id TEXT PRIMARY KEY,
  sales_channel_id TEXT NOT NULL,
  title TEXT NOT NULL,
  handle TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  CONSTRAINT merchant_collections_sales_channel_handle_unique
    UNIQUE (sales_channel_id, handle)
);

CREATE UNIQUE INDEX IF NOT EXISTS merchant_collections_handle_idx
  ON merchant_collections (handle);

-- merchant_category_products
CREATE TABLE IF NOT EXISTS merchant_category_products (
  category_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  PRIMARY KEY (category_id, product_id),
  CONSTRAINT merchant_category_products_category_fk
    FOREIGN KEY (category_id)
    REFERENCES merchant_categories(id)
    ON DELETE CASCADE
);

-- merchant_collection_products
CREATE TABLE IF NOT EXISTS merchant_collection_products (
  collection_id TEXT NOT NULL,
  product_id TEXT NOT NULL,
  PRIMARY KEY (collection_id, product_id),
  CONSTRAINT merchant_collection_products_collection_fk
    FOREIGN KEY (collection_id)
    REFERENCES merchant_collections(id)
    ON DELETE CASCADE
);
