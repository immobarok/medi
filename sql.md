Project hospital_queue_management_system {
  database_type: "PostgreSQL"
  Note: "Digital Hospital Queue Management System database design. PostgreSQL is the source of truth. Redis should be used separately for realtime queue cache, Socket.IO pub/sub, and active display state."
}

/* =========================
   ENUMS
========================= */

Enum user_status {
  ACTIVE
  INACTIVE
  BLOCKED
}

Enum doctor_status {
  AVAILABLE
  BUSY
  BREAK
  OFFLINE
}

Enum gender_type {
  MALE
  FEMALE
  OTHER
}

Enum visit_type {
  QUEUE
  APPOINTMENT
  EMERGENCY
  FOLLOW_UP
}

Enum appointment_status {
  SCHEDULED
  CONFIRMED
  ARRIVED
  CONVERTED_TO_QUEUE
  CANCELLED
  COMPLETED
  NO_SHOW
}

Enum booking_source {
  RECEPTION
  ADMIN
  PATIENT_PORTAL
  PHONE_CALL
}

Enum queue_status {
  WAITING
  CALLED
  IN_PROGRESS
  COMPLETED
  SKIPPED
  CANCELLED
}

Enum priority_level {
  NORMAL
  PRIORITY
  EMERGENCY
}

Enum notification_channel {
  SMS
  EMAIL
  WHATSAPP
  PUSH
}

Enum notification_status {
  PENDING
  SENT
  FAILED
  CANCELLED
}

Enum schedule_exception_type {
  UNAVAILABLE
  EXTRA_AVAILABLE
  HOLIDAY
  LEAVE
}

/* =========================
   HOSPITAL SETUP
========================= */

Table hospitals {
  id uuid [pk]
  name varchar(150) [not null]
  logo_url text
  address text
  contact_number varchar(30)
  timezone varchar(80) [default: "Asia/Dhaka"]
  working_hours jsonb
  token_settings jsonb
  is_active boolean [default: true]
  created_at timestamp
  updated_at timestamp
}

Table departments {
  id uuid [pk]
  hospital_id uuid [not null]
  name varchar(120) [not null]
  code varchar(20) [not null]
  description text
  is_active boolean [default: true]
  created_at timestamp
  updated_at timestamp

  indexes {
    (hospital_id, code) [unique]
    (hospital_id, name) [unique]
    hospital_id
  }
}

Table rooms {
  id uuid [pk]
  hospital_id uuid [not null]
  room_number varchar(50) [not null]
  floor varchar(50)
  description text
  is_active boolean [default: true]
  created_at timestamp

  indexes {
    (hospital_id, room_number) [unique]
    hospital_id
  }
}

/* =========================
   AUTHENTICATION & RBAC
========================= */

Table users {
  id uuid [pk]
  hospital_id uuid
  full_name varchar(150) [not null]
  email varchar(150) [not null, unique]
  phone varchar(30)
  password_hash text [not null]
  status user_status [default: "ACTIVE"]
  last_login_at timestamp
  created_at timestamp
  updated_at timestamp

  indexes {
    hospital_id
    email
    phone
  }
}

Table roles {
  id uuid [pk]
  name varchar(80) [not null]
  code varchar(50) [not null, unique]
  description text
}

Table permissions {
  id uuid [pk]
  name varchar(120) [not null]
  code varchar(100) [not null, unique]
}

Table user_roles {
  id uuid [pk]
  user_id uuid [not null]
  role_id uuid [not null]

  indexes {
    (user_id, role_id) [unique]
    user_id
    role_id
  }
}

Table role_permissions {
  id uuid [pk]
  role_id uuid [not null]
  permission_id uuid [not null]

  indexes {
    (role_id, permission_id) [unique]
    role_id
    permission_id
  }
}

/* =========================
   DOCTOR MANAGEMENT
========================= */

Table doctors {
  id uuid [pk]
  hospital_id uuid [not null]
  user_id uuid
  department_id uuid [not null]
  room_id uuid

  name varchar(150) [not null]
  specialization varchar(150)
  qualification varchar(150)
  consultation_fee numeric(10,2)
  status doctor_status [default: "OFFLINE"]

  is_available_for_queue boolean [default: true]
  is_bookable boolean [default: true]

  created_at timestamp
  updated_at timestamp

  indexes {
    (hospital_id, department_id)
    (hospital_id, status)
    user_id
    room_id
  }
}

Table doctor_schedules {
  id uuid [pk]
  hospital_id uuid [not null]
  doctor_id uuid [not null]

  day_of_week smallint [not null, note: "0 = Sunday, 6 = Saturday"]
  start_time time [not null]
  end_time time [not null]
  slot_duration_minutes int [default: 15]
  max_patients int

  is_active boolean [default: true]
  created_at timestamp

  indexes {
    (hospital_id, doctor_id, day_of_week)
    doctor_id
  }
}

Table doctor_schedule_exceptions {
  id uuid [pk]
  hospital_id uuid [not null]
  doctor_id uuid [not null]

  exception_date date [not null]
  start_time time
  end_time time
  exception_type schedule_exception_type [not null]
  reason text

  created_at timestamp

  indexes {
    (doctor_id, exception_date, exception_type) [unique]
    (hospital_id, doctor_id, exception_date)
  }
}

/* =========================
   PATIENT MANAGEMENT
========================= */

Table patients {
  id uuid [pk]
  hospital_id uuid [not null]

  patient_code varchar(50) [not null]
  full_name varchar(150) [not null]
  phone varchar(30) [not null]
  normalized_phone varchar(30) [not null]

  age int
  gender gender_type
  date_of_birth date
  address text

  created_at timestamp
  updated_at timestamp

  indexes {
    (hospital_id, patient_code) [unique]
    (hospital_id, normalized_phone) [unique]
    (hospital_id, full_name)
    hospital_id
  }
}

Table patient_visits {
  id uuid [pk]
  hospital_id uuid [not null]
  patient_id uuid [not null]
  department_id uuid
  doctor_id uuid

  visit_date date [not null]
  visit_type visit_type [default: "QUEUE"]
  notes text

  created_at timestamp

  indexes {
    (hospital_id, patient_id)
    (hospital_id, visit_date)
    department_id
    doctor_id
  }
}

/* =========================
   APPOINTMENT BOOKING
========================= */

Table appointments {
  id uuid [pk]
  hospital_id uuid [not null]

  patient_id uuid [not null]
  doctor_id uuid [not null]
  department_id uuid [not null]

  appointment_date date [not null]
  start_time time [not null]
  end_time time [not null]

  status appointment_status [default: "SCHEDULED"]
  booking_source booking_source [default: "RECEPTION"]

  reason text
  notes text

  arrived_at timestamp
  cancelled_at timestamp
  completed_at timestamp

  created_by uuid
  created_at timestamp
  updated_at timestamp

  indexes {
    (hospital_id, doctor_id, appointment_date)
    (hospital_id, patient_id)
    (hospital_id, status, appointment_date)
    (doctor_id, appointment_date, start_time) [unique]
  }

  Note: "Unique doctor slot should exclude CANCELLED and NO_SHOW in real PostgreSQL using a partial unique index."
}

/* =========================
   QUEUE MANAGEMENT
========================= */

Table queue_daily_counters {
  id uuid [pk]
  hospital_id uuid [not null]
  department_id uuid
  doctor_id uuid

  queue_date date [not null]
  prefix varchar(20) [not null]
  last_sequence int [default: 0]

  created_at timestamp
  updated_at timestamp

  indexes {
    (hospital_id, department_id, doctor_id, queue_date) [unique]
    (hospital_id, queue_date)
  }

  Note: "Use this table for fast token generation. Do not generate token numbers using COUNT(*)."
}

Table queue_tokens {
  id uuid [pk]
  hospital_id uuid [not null]

  patient_id uuid [not null]
  visit_id uuid
  appointment_id uuid

  department_id uuid [not null]
  doctor_id uuid

  queue_date date [not null]

  token_prefix varchar(20) [not null]
  token_sequence int [not null]
  token_number varchar(50) [not null]

  status queue_status [default: "WAITING"]
  priority_level priority_level [default: "NORMAL"]

  queue_position int

  created_by uuid
  called_by uuid
  completed_by uuid

  created_at timestamp
  called_at timestamp
  started_at timestamp
  completed_at timestamp
  skipped_at timestamp
  cancelled_at timestamp

  cancellation_reason text
  notes text

  indexes {
    (hospital_id, queue_date, token_number) [unique]
    (hospital_id, doctor_id, queue_date, priority_level, created_at)
    (hospital_id, department_id, queue_date, priority_level, created_at)
    (hospital_id, queue_date, status)
    (hospital_id, patient_id, queue_date)
    appointment_id
    visit_id
  }

  Note: "In real PostgreSQL, add partial indexes for active queue only: status IN ('WAITING', 'SKIPPED'). This keeps doctor Call Next queries very fast."
}

Table queue_token_events {
  id uuid [pk]
  hospital_id uuid [not null]
  queue_token_id uuid [not null]

  old_status queue_status
  new_status queue_status [not null]

  action varchar(80) [not null]
  performed_by uuid

  metadata jsonb
  created_at timestamp

  indexes {
    (queue_token_id, created_at)
    (hospital_id, created_at)
    performed_by
  }

  Note: "Append-only event table for audit, debugging, and analytics."
}

/* =========================
   NOTIFICATIONS
========================= */

Table notifications {
  id uuid [pk]
  hospital_id uuid [not null]

  patient_id uuid
  appointment_id uuid
  queue_token_id uuid

  channel notification_channel [not null]
  notification_type varchar(50) [not null]

  recipient varchar(100) [not null]
  message text [not null]

  status notification_status [default: "PENDING"]
  provider_response jsonb

  scheduled_at timestamp
  sent_at timestamp
  failed_at timestamp

  created_at timestamp

  indexes {
    (hospital_id, status, scheduled_at)
    patient_id
    appointment_id
    queue_token_id
  }
}

Table sms_logs {
  id uuid [pk]
  notification_id uuid
  hospital_id uuid [not null]

  provider_name varchar(80)
  provider_message_id varchar(150)
  phone varchar(30)

  status varchar(30)
  error_message text
  raw_response jsonb

  created_at timestamp

  indexes {
    notification_id
    (hospital_id, created_at)
    provider_message_id
  }
}

/* =========================
   REPORTING
========================= */

Table daily_queue_stats {
  id uuid [pk]
  hospital_id uuid [not null]
  department_id uuid
  doctor_id uuid

  report_date date [not null]

  total_tokens int [default: 0]
  completed_tokens int [default: 0]
  cancelled_tokens int [default: 0]
  skipped_tokens int [default: 0]
  emergency_tokens int [default: 0]

  avg_waiting_seconds int [default: 0]
  avg_consultation_seconds int [default: 0]

  created_at timestamp
  updated_at timestamp

  indexes {
    (hospital_id, department_id, doctor_id, report_date) [unique]
    (hospital_id, report_date)
  }

  Note: "Use this table for fast dashboard and monthly reporting instead of recalculating from all queue tokens every time."
}

/* =========================
   AUDIT LOGS
========================= */

Table audit_logs {
  id uuid [pk]
  hospital_id uuid

  user_id uuid
  action varchar(100) [not null]
  module varchar(80) [not null]

  resource_type varchar(80)
  resource_id uuid

  old_data jsonb
  new_data jsonb

  ip_address varchar(80)
  user_agent text

  created_at timestamp

  indexes {
    (hospital_id, created_at)
    (resource_type, resource_id)
    user_id
  }
}

/* =========================
   RELATIONSHIPS
========================= */

Ref: departments.hospital_id > hospitals.id [delete: cascade]
Ref: rooms.hospital_id > hospitals.id [delete: cascade]

Ref: users.hospital_id > hospitals.id [delete: cascade]
Ref: user_roles.user_id > users.id [delete: cascade]
Ref: user_roles.role_id > roles.id [delete: cascade]
Ref: role_permissions.role_id > roles.id [delete: cascade]
Ref: role_permissions.permission_id > permissions.id [delete: cascade]

Ref: doctors.hospital_id > hospitals.id [delete: cascade]
Ref: doctors.user_id > users.id [delete: set null]
Ref: doctors.department_id > departments.id
Ref: doctors.room_id > rooms.id

Ref: doctor_schedules.hospital_id > hospitals.id [delete: cascade]
Ref: doctor_schedules.doctor_id > doctors.id [delete: cascade]

Ref: doctor_schedule_exceptions.hospital_id > hospitals.id [delete: cascade]
Ref: doctor_schedule_exceptions.doctor_id > doctors.id [delete: cascade]

Ref: patients.hospital_id > hospitals.id [delete: cascade]

Ref: patient_visits.hospital_id > hospitals.id [delete: cascade]
Ref: patient_visits.patient_id > patients.id [delete: cascade]
Ref: patient_visits.department_id > departments.id
Ref: patient_visits.doctor_id > doctors.id

Ref: appointments.hospital_id > hospitals.id [delete: cascade]
Ref: appointments.patient_id > patients.id [delete: cascade]
Ref: appointments.doctor_id > doctors.id
Ref: appointments.department_id > departments.id
Ref: appointments.created_by > users.id

Ref: queue_daily_counters.hospital_id > hospitals.id [delete: cascade]
Ref: queue_daily_counters.department_id > departments.id
Ref: queue_daily_counters.doctor_id > doctors.id

Ref: queue_tokens.hospital_id > hospitals.id [delete: cascade]
Ref: queue_tokens.patient_id > patients.id
Ref: queue_tokens.visit_id > patient_visits.id
Ref: queue_tokens.appointment_id > appointments.id
Ref: queue_tokens.department_id > departments.id
Ref: queue_tokens.doctor_id > doctors.id
Ref: queue_tokens.created_by > users.id
Ref: queue_tokens.called_by > users.id
Ref: queue_tokens.completed_by > users.id

Ref: queue_token_events.hospital_id > hospitals.id [delete: cascade]
Ref: queue_token_events.queue_token_id > queue_tokens.id [delete: cascade]
Ref: queue_token_events.performed_by > users.id

Ref: notifications.hospital_id > hospitals.id [delete: cascade]
Ref: notifications.patient_id > patients.id
Ref: notifications.appointment_id > appointments.id
Ref: notifications.queue_token_id > queue_tokens.id

Ref: sms_logs.notification_id > notifications.id [delete: cascade]
Ref: sms_logs.hospital_id > hospitals.id [delete: cascade]

Ref: daily_queue_stats.hospital_id > hospitals.id [delete: cascade]
Ref: daily_queue_stats.department_id > departments.id
Ref: daily_queue_stats.doctor_id > doctors.id

Ref: audit_logs.hospital_id > hospitals.id [delete: cascade]
Ref: audit_logs.user_id > users.id