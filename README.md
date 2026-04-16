# Tiba Mobile Admin

Flutter admin application for managing Tiba Trade data through the backend API.

## 1. Overview

This app allows authenticated admins to:

- Manage categories and subcategories.
- Manage products and pricing rules per user segment.
- Manage offers.
- Monitor and update orders and order items.
- Manage users and user segments.
- Upload images to the backend and attach URLs to entities.
- Sign out from current device or all devices.

Role behavior:

- `admin`: full tab set (categories, subcategories, products, offers, orders, users, segments, pricing, account).
- non-admin: limited tabs (categories + account).

## 2. App Flow

1. App launches to auth gate.
2. If refresh token works, user is routed to home.
3. Otherwise user is routed to login.
4. Home shows tabs based on stored role.

## 3. API Connection

The app uses `ApiConfig.baseUrl`.

Defaults:

- Environment: `dev`
- Dev base URL: `http://192.168.1.30:6543`

`DART_DEFINE` values supported:

- `DART_DEFINE_ENV=dev|staging|prod`
- `DART_DEFINE_DEV_BASE_URL=<url>`

Example run command:

```bash
flutter run --dart-define=DART_DEFINE_ENV=dev --dart-define=DART_DEFINE_DEV_BASE_URL=http://192.168.1.30:6543
```

## 4. Authentication and Session

- Login endpoint: `POST /auth/login`
- Refresh endpoint: `POST /auth/refresh`
- Logout current device: `POST /auth/logout`
- Logout all devices: `POST /auth/logout-all`

Login payload sent by app:

```json
{
	"email": "admin@example.com",
	"password": "secret123",
	"device_id": "generated_device_id",
	"device_name": "android-admin"
}
```

Stored locally:

- `access_token`
- `refresh_token`
- `role`

## 5. Pages and Features

### 5.1 Auth Gate Page

- Silent loading page.
- Tries auto-login with refresh token.
- Redirects to login/home.

### 5.2 Login Page

- Inputs: email, password.
- Validation for email/password format.
- On success, goes to Home.

### 5.3 Home Page

- Bottom navigation tabs.
- Preloads product lookup and user segments for dependent pages.

### 5.4 Categories Page

- List, search, infinite scroll, pull-to-refresh.
- Add/edit in bottom sheet.
- Delete with confirmation.
- Image upload supported.

Fields editable:

- `name`
- `arabic_name`
- `is_active`
- `image_url` (via upload)

Backend endpoints used:

- `GET /categories`
- `POST /categories/create`
- `PUT /categories/update/{id}`
- `DELETE /categories/delete/{id}`

### 5.5 Subcategories Page

- List/search CRUD like categories.
- Category dropdown is required when creating/updating.
- Image upload supported.

Fields editable:

- `category_id`
- `name`
- `arabic_name`
- `image_url`
- `is_active`

Backend endpoints used:

- `GET /subcategories`
- `POST /subcategories/create`
- `PUT /subcategories/update/{id}`
- `DELETE /subcategories/delete/{id}`

### 5.6 Products Page

- List/search CRUD.
- Category and subcategory dropdowns.
- Image upload supported.

Fields editable in form:

- `name`
- `arabic_name`
- `manufacturer_name` (sent by app)
- `arabic_manufacturer_name` (sent by app)
- `description`
- `arabic_description`
- `image_url`
- `category_id`
- `subcategory_id`
- `is_active`

Backend endpoints used:

- `GET /products`
- `GET /products/get/{id}`
- `POST /products/create`
- `PUT /products/update/{id}`
- `DELETE /products/delete/{id}`

### 5.7 Offers Page

- List/search CRUD.
- Date pickers for start/end date.
- Active toggle.
- UI supports uploading an image URL, but current create/update controller methods send only:
	- title
	- description
	- start_date
	- end_date
	- is_active

Backend endpoints used:

- `GET /offers`
- `GET /offers/get/{id}`
- `POST /offers/create`
- `PUT /offers/update/{id}`
- `DELETE /offers/delete/{id}`

### 5.8 Orders Page

- List orders with expandable order items.
- Update order status.
- Update individual item qty/price/status.
- Delete order.

Order status options in UI:

- `pending`
- `processing`
- `shipped`
- `delivered`
- `cancelled`
- `returned`

Order item status options in UI:

- `active`
- `cancelled`
- `returned`
- `out_of_stock`

Backend endpoints used:

- `GET /orders`
- `PUT /orders/update/{id}`
- `PUT /orders/{order_id}/items/{item_id}`
- `DELETE /orders/delete/{id}`

### 5.9 Users Page

- List/search users.
- Edit user fields (no create page in app).
- Delete user.

Fields editable:

- `first_name`
- `last_name`
- `segment_id`
- `role_id`
- `loyalty_points`
- `wallet_balance`
- `is_active`
- `is_verified`

Backend endpoints used:

- `GET /users`
- `PUT /users/update/{id}`
- `DELETE /users/delete/{id}`

### 5.10 User Segments Page

- List/search/create/update/delete segments.

Fields editable:

- `name`
- `arabic_name`
- `is_active`

Backend endpoints used:

- `GET /user_segments`
- `POST /user_segments/create`
- `PUT /user_segments/update/{id}`
- `DELETE /user_segments/delete/{id}`

### 5.11 Price Segments Page (Pricing Rules)

- List/search pricing rules.
- Create rule by selecting product and user segment.
- Edit or delete existing rule.

Fields editable:

- `product_id` (create only)
- `segment_id` (create only)
- `is_retail`
- `retail_price`
- `retail_lowest_order_quantity`
- `retail_max_order_quantity`
- `is_wholesale`
- `wholesale_price`
- `wholesale_lowest_order_quantity`
- `wholesale_max_order_quantity`
- `offer_percent`

Backend endpoints used:

- `GET /price_segments`
- `POST /price_segments/create`
- `PUT /price_segments/update/{id}`
- `DELETE /price_segments/delete/{id}`

### 5.12 Account Page

- Log out from current device.
- Log out from all devices.

## 6. How to Add / Edit / Delete Data

This section summarizes the exact admin workflow pattern for all entities.

### Add

1. Open the entity tab.
2. Tap floating `+` button.
3. Fill form fields.
4. For images: tap upload icon and choose image from gallery.
5. Tap `Create` or `Save`.

### Edit

1. Find item in list (search supported).
2. Tap edit icon on row.
3. Update desired fields.
4. Tap `Save`.

### Delete

1. Tap delete icon on row.
2. Confirm dialog.
3. Item is removed through API and list refreshes.

## 7. Shared List Behavior (All CRUD Tabs)

- Search bar at top.
- Infinite scroll pagination.
- Pull to refresh.
- Empty state with refresh hint.
- Local cache on some controllers for faster initial load.

## 8. Image Upload Rules

Upload service constraints:

- Max file size: 5 MB
- Allowed formats: `jpg`, `jpeg`, `png`, `webp`
- API endpoint: `POST /upload/image` (multipart)
- Expects response field `full_image_url`

## 9. Not Implemented in Mobile UI (Backend Exists)

The backend has endpoints for these, but no dedicated tab/page in current mobile admin:

- Addresses CRUD
- Banners CRUD
- Notification send endpoints (`/notify/...`)
- Email test endpoint

## 10. Build and Run

1. Install dependencies:

```bash
flutter pub get
```

2. Run app:

```bash
flutter run
```

3. Optional static checks:

```bash
flutter analyze
```

## 11. API Quick Reference (Single-Page Cheat Sheet)

Use this section as a compact daily reference while using the admin app.

### 11.1 Auth Endpoints

| Method | Path | Used By | Notes |
|---|---|---|---|
| POST | /auth/login | Login page | Requires email, password, device_id. |
| POST | /auth/refresh | Auth gate | Refreshes access token using refresh token + device_id. |
| POST | /auth/logout | Account page | Logout current device (revokes session). |
| POST | /auth/logout-all | Account page | Logout all user sessions on all devices. |

### 11.2 Screen-to-Endpoint Map

| Screen | List | Create | Update | Delete |
|---|---|---|---|---|
| Categories | GET /categories | POST /categories/create | PUT /categories/update/{id} | DELETE /categories/delete/{id} |
| Subcategories | GET /subcategories | POST /subcategories/create | PUT /subcategories/update/{id} | DELETE /subcategories/delete/{id} |
| Products | GET /products | POST /products/create | PUT /products/update/{id} | DELETE /products/delete/{id} |
| Offers | GET /offers | POST /offers/create | PUT /offers/update/{id} | DELETE /offers/delete/{id} |
| Orders | GET /orders | Not exposed in UI | PUT /orders/update/{id}, PUT /orders/{order_id}/items/{item_id} | DELETE /orders/delete/{id} |
| Users | GET /users | Not exposed in UI | PUT /users/update/{id} | DELETE /users/delete/{id} |
| User Segments | GET /user_segments | POST /user_segments/create | PUT /user_segments/update/{id} | DELETE /user_segments/delete/{id} |
| Price Segments | GET /price_segments | POST /price_segments/create | PUT /price_segments/update/{id} | DELETE /price_segments/delete/{id} |

### 11.3 Shared Query Parameters

Most list endpoints support:

| Param | Purpose |
|---|---|
| page | Current page number |
| per_page | Page size |
| limit | Alternate page-size key |
| q | Search term |

Some endpoints support extra filters:

| Endpoint | Extra Filters |
|---|---|
| /subcategories | category_id |
| /orders | user_id |
| /price_segments | product_id |

### 11.4 Copy/Paste Payload Snippets

Login:

```json
{
	"email": "admin@example.com",
	"password": "secret123",
	"device_id": "android-device-001",
	"device_name": "android-admin"
}
```

Category create:

```json
{
	"name": "Food",
	"arabic_name": "طعام",
	"is_active": true,
	"image_url": "https://..."
}
```

Subcategory create:

```json
{
	"category_id": 1,
	"name": "Snacks",
	"arabic_name": "سناكس",
	"is_active": true,
	"image_url": "https://..."
}
```

Product create:

```json
{
	"name": "Product A",
	"arabic_name": "منتج",
	"description": "Description",
	"arabic_description": "وصف",
	"category_id": 1,
	"subcategory_id": 2,
	"is_active": true,
	"image_url": "https://..."
}
```

Offer create:

```json
{
	"title": "Flash Sale",
	"description": "Limited time",
	"start_date": "2026-04-16T00:00:00",
	"end_date": "2026-04-20T23:59:59",
	"is_active": true
}
```

User update:

```json
{
	"first_name": "John",
	"last_name": "Doe",
	"segment_id": 2,
	"role_id": 1,
	"loyalty_points": 10,
	"wallet_balance": 100.0,
	"is_active": true,
	"is_verified": true
}
```

User segment create:

```json
{
	"name": "Retail",
	"arabic_name": "قطاع التجزئة",
	"is_active": true
}
```

Price segment create:

```json
{
	"product_id": 10,
	"segment_id": 2,
	"is_retail": true,
	"retail_price": 15.0,
	"retail_lowest_order_quantity": 1,
	"retail_max_order_quantity": 20,
	"is_wholesale": true,
	"wholesale_price": 12.5,
	"wholesale_lowest_order_quantity": 21,
	"wholesale_max_order_quantity": 500,
	"offer_percent": 5
}
```

Order status update:

```json
{ "status": "processing" }
```

Order item update:

```json
{ "qty": 3, "price": 49.0, "status": "active" }
```

### 11.5 Upload Endpoint (Used by image forms)

| Method | Path | Content Type | Required Fields | Response |
|---|---|---|---|---|
| POST | /upload/image | multipart/form-data | image, folder(optional) | image_url + full_image_url |

Allowed image rules in app:

- Max 5 MB
- jpg, jpeg, png, webp

### 11.6 Backend APIs Not Yet Exposed as Mobile Tabs

- Addresses CRUD (`/addresses/...`)
- Banners CRUD (`/banners/...`)
- Notifications (`/notify/...`)
- Email test (`/email/test`)
