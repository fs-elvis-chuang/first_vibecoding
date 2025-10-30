### 1. 文件元數據 (Document Metadata)
- **文件標題**: `資料庫綱要定義文檔`
- **文件版本**: `v1.0.0`
- **作者**: `Gemini (資料庫管理員)`

---

### 2. 設計原則與選型 (Design Principles & Engine)

- **正規化 (Normalization)**: 本次設計將遵循**第三正規化 (3NF)** 原則。所有欄位都直接依賴於該資料表的主鍵，旨在消除數據冗餘，確保資料的完整性與一致性，為未來的數據擴展打下良好基礎。

- **資料庫引擎**: **SQLite**
  - **理由 1 (輕量與零配置)**: SQLite 是一個無伺服器、基於檔案的資料庫引擎，無需獨立的伺服器進程或複雜的設定。這使得開發環境的搭建極為簡便，非常適合 MVP 階段的快速啟動與迭代。
  - **理由 2 (易於整合與測試)**: 由於其輕量特性，SQLite 能輕易地與 Python 應用程式整合，並方便進行單元測試與整合測試，可為每個測試案例建立獨立的記憶體資料庫。

---

### 3. 資料表定義 (Table Definitions)

#### `users`
- **用途說明**: 儲存應用程式所有使用者的基本資料與認證資訊。
- **欄位詳解**:

| 欄位名稱 | 資料類型 (SQLite) | 約束/索引 | 欄位描述 |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PK`, `AUTOINCREMENT` | 使用者唯一識別碼 |
| `email` | `TEXT` | `UNIQUE`, `NOT NULL`, `INDEX` | 使用者登入 Email，建立索引以加速查詢 |
| `password_hash` | `TEXT` | `NOT NULL` | 加密後的密碼雜湊值 |
| `created_at` | `TEXT` | `NOT NULL` | 使用者帳號建立時間 (ISO 8601 格式) |

#### `habits`
- **用途說明**: 儲存使用者定義的「習慣」項目本身，例如習慣的名稱。
- **欄位詳解**:

| 欄位名稱 | 資料類型 (SQLite) | 約束/索引 | 欄位描述 |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PK`, `AUTOINCREMENT` | 習慣唯一識別碼 |
| `user_id` | `INTEGER` | `FK (users.id)`, `NOT NULL`, `INDEX` | 關聯至 `users` 資料表，表示該習慣的擁有者 |
| `name` | `TEXT` | `NOT NULL` | 習慣的名稱 (例如：「每日運動」) |
| `created_at` | `TEXT` | `NOT NULL` | 習慣建立時間 (ISO 8601 格式) |

#### `habit_logs`
- **用途說明**: 記錄使用者每一次「完成習慣」的打卡行為，與 `habits` 表分離以追蹤歷史紀錄。
- **欄位詳解**:

| 欄位名稱 | 資料類型 (SQLite) | 約束/索引 | 欄位描述 |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PK`, `AUTOINCREMENT` | 打卡紀錄唯一識別碼 |
| `habit_id` | `INTEGER` | `FK (habits.id)`, `NOT NULL`, `INDEX` | 關聯至 `habits` 資料表 |
| `date_completed` | `TEXT` | `NOT NULL` | 完成習慣的日期 (格式: YYYY-MM-DD) |

#### `mood_logs`
- **用途說明**: 記錄使用者每日的心情分數與相關筆記。
- **欄位詳解**:

| 欄位名稱 | 資料類型 (SQLite) | 約束/索引 | 欄位描述 |
| :--- | :--- | :--- | :--- |
| `id` | `INTEGER` | `PK`, `AUTOINCREMENT` | 心情紀錄唯一識別碼 |
| `user_id` | `INTEGER` | `FK (users.id)`, `NOT NULL`, `INDEX` | 關聯至 `users` 資料表 |
| `mood_score` | `INTEGER` | `NOT NULL` | 心情分數 (例如 1-5 的整數) |
| `notes` | `TEXT` | | 使用者對當天心情的簡短筆記 (可選填) |
| `date` | `TEXT` | `NOT NULL` | 記錄心情的日期 (格式: YYYY-MM-DD) |

---

### 4. 實體關係圖 (Entity-Relationship Diagram - ERD)

```mermaid
erDiagram
    users ||--o{ habits : owns
    users ||--o{ mood_logs : logs
    habits ||--o{ habit_logs : has

    users {
        INTEGER id PK
        TEXT email UNIQUE, INDEX
        TEXT password_hash
        TEXT created_at
    }
    habits {
        INTEGER id PK
        INTEGER user_id FK
        TEXT name
        TEXT created_at
    }
    habit_logs {
        INTEGER id PK
        INTEGER habit_id FK
        TEXT date_completed
    }
    mood_logs {
        INTEGER id PK
        INTEGER user_id FK
        INTEGER mood_score
        TEXT notes
        TEXT date
    }
```

---

### 5. 關聯文字說明 (Relationship Description)

- **users 與 habits**: 一對多 (`One-to-Many`) 關係。一個 `user` 可以擁有多個 `habits`。
- **users 與 mood_logs**: 一對多 (`One-to-Many`) 關係。一個 `user` 可以擁有多筆 `mood_logs`。
- **habits 與 habit_logs**: 一對多 (`One-to-Many`) 關係。一個 `habit` (習慣定義) 可以對應多筆 `habit_logs` (完成紀錄)。

---

### 6. 資料庫填充腳本 (Database Seeding Script)

```sql
-- 清除舊資料 (方便重複執行)
DELETE FROM mood_logs;
DELETE FROM habit_logs;
DELETE FROM habits;
DELETE FROM users;

-- 插入範例使用者
INSERT INTO users (id, email, password_hash, created_at) VALUES
(1, 'user1@example.com', 'hashed_password_1', '2025-10-31T10:00:00Z'),
(2, 'user2@example.com', 'hashed_password_2', '2025-10-31T11:00:00Z');

-- 插入範例習慣 (屬於 user 1)
INSERT INTO habits (id, user_id, name, created_at) VALUES
(1, 1, '每日運動', '2025-10-31T10:05:00Z'),
(2, 1, '冥想 10 分鐘', '2025-10-31T10:06:00Z');

-- 插入範例習慣打卡紀錄 (user 1 的「每日運動」)
INSERT INTO habit_logs (habit_id, date_completed) VALUES
(1, '2025-10-29'),
(1, '2025-10-30');

-- 插入範例心情紀錄 (屬於 user 1)
INSERT INTO mood_logs (user_id, mood_score, notes, date) VALUES
(1, 5, '今天運動後感覺很棒！', '2025-10-29'),
(1, 4, '工作有點累，但還行。', '2025-10-30');
```
