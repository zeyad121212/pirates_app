// Database schema for the Pirates App
// This file contains the structure of our Supabase tables

/*
Table: users
- id: uuid (primary key)
- code: text (unique)
- role: text (enum: PM, TR, MB, CC, SV)
- password: text
- name: text
- email: text
- points: int (for trainers)
- specialties: jsonb[]
- created_at: timestamp
- last_login: timestamp

Table: training_sessions
- id: uuid (primary key)
- title: text
- description: text
- trainer_id: uuid (references users.id)
- status: text (enum: pending, approved, rejected, completed)
- location: text
- start_date: timestamp
- end_date: timestamp
- created_by: uuid (references users.id)
- created_at: timestamp

Table: points_transactions
- id: uuid (primary key)
- trainer_id: uuid (references users.id)
- points: int
- reason: text
- created_at: timestamp

Table: messages
- id: uuid (primary key)
- sender_id: uuid (references users.id)
- receiver_id: uuid (references users.id)
- content: text
- read: boolean
- created_at: timestamp

Table: notifications
- id: uuid (primary key)
- user_id: uuid (references users.id)
- title: text
- content: text
- type: text (enum: task, message, points, system)
- read: boolean
- created_at: timestamp

Table: training_materials
- id: uuid (primary key)
- title: text
- content: text
- created_by: uuid (references users.id)
- ai_enhanced: boolean
- created_at: timestamp
- updated_at: timestamp

Table: reports
- id: uuid (primary key)
- title: text
- type: text (enum: performance, feedback, summary)
- content: jsonb
- created_by: uuid (references users.id)
- created_at: timestamp
*/

// Supabase RLS Policies will be implemented for each table to ensure:
// 1. Users can only access data relevant to their role
// 2. Trainers can only view and modify their own training sessions
// 3. Project Managers have full access to all data
// 4. Monitoring Board Members have read access to all training data
// 5. Messages are only visible to sender and receiver
