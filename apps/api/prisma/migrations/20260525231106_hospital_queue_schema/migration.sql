/*
  Warnings:

  - You are about to drop the `Post` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- CreateEnum
CREATE TYPE "user_status" AS ENUM ('ACTIVE', 'INACTIVE', 'BLOCKED');

-- CreateEnum
CREATE TYPE "doctor_status" AS ENUM ('AVAILABLE', 'BUSY', 'BREAK', 'OFFLINE');

-- CreateEnum
CREATE TYPE "gender_type" AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- CreateEnum
CREATE TYPE "visit_type" AS ENUM ('QUEUE', 'APPOINTMENT', 'EMERGENCY', 'FOLLOW_UP');

-- CreateEnum
CREATE TYPE "appointment_status" AS ENUM ('SCHEDULED', 'CONFIRMED', 'ARRIVED', 'CONVERTED_TO_QUEUE', 'CANCELLED', 'COMPLETED', 'NO_SHOW');

-- CreateEnum
CREATE TYPE "booking_source" AS ENUM ('RECEPTION', 'ADMIN', 'PATIENT_PORTAL', 'PHONE_CALL');

-- CreateEnum
CREATE TYPE "queue_status" AS ENUM ('WAITING', 'CALLED', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "priority_level" AS ENUM ('NORMAL', 'PRIORITY', 'EMERGENCY');

-- CreateEnum
CREATE TYPE "notification_channel" AS ENUM ('SMS', 'EMAIL', 'WHATSAPP', 'PUSH');

-- CreateEnum
CREATE TYPE "notification_status" AS ENUM ('PENDING', 'SENT', 'FAILED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "schedule_exception_type" AS ENUM ('UNAVAILABLE', 'EXTRA_AVAILABLE', 'HOLIDAY', 'LEAVE');

-- DropForeignKey
ALTER TABLE "Post" DROP CONSTRAINT "Post_authorId_fkey";

-- DropTable
DROP TABLE "Post";

-- DropTable
DROP TABLE "User";

-- CreateTable
CREATE TABLE "appointments" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "patient_id" UUID NOT NULL,
    "doctor_id" UUID NOT NULL,
    "department_id" UUID NOT NULL,
    "appointment_date" DATE NOT NULL,
    "start_time" TIME(6) NOT NULL,
    "end_time" TIME(6) NOT NULL,
    "status" "appointment_status" NOT NULL DEFAULT 'SCHEDULED',
    "booking_source" "booking_source" NOT NULL DEFAULT 'RECEPTION',
    "reason" TEXT,
    "notes" TEXT,
    "arrived_at" TIMESTAMP(6),
    "cancelled_at" TIMESTAMP(6),
    "completed_at" TIMESTAMP(6),
    "created_by" UUID,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "appointments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "audit_logs" (
    "id" UUID NOT NULL,
    "hospital_id" UUID,
    "user_id" UUID,
    "action" VARCHAR(100) NOT NULL,
    "module" VARCHAR(80) NOT NULL,
    "resource_type" VARCHAR(80),
    "resource_id" UUID,
    "old_data" JSONB,
    "new_data" JSONB,
    "ip_address" VARCHAR(80),
    "user_agent" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "hospital_id" UUID,
    "full_name" VARCHAR(150) NOT NULL,
    "email" VARCHAR(150) NOT NULL,
    "phone" VARCHAR(30),
    "password_hash" TEXT NOT NULL,
    "status" "user_status" NOT NULL DEFAULT 'ACTIVE',
    "last_login_at" TIMESTAMP(6),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roles" (
    "id" UUID NOT NULL,
    "name" VARCHAR(80) NOT NULL,
    "code" VARCHAR(50) NOT NULL,
    "description" TEXT,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "permissions" (
    "id" UUID NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "code" VARCHAR(100) NOT NULL,

    CONSTRAINT "permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_roles" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "role_id" UUID NOT NULL,

    CONSTRAINT "user_roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "role_permissions" (
    "id" UUID NOT NULL,
    "role_id" UUID NOT NULL,
    "permission_id" UUID NOT NULL,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "doctors" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "user_id" UUID,
    "department_id" UUID NOT NULL,
    "room_id" UUID,
    "name" VARCHAR(150) NOT NULL,
    "specialization" VARCHAR(150),
    "qualification" VARCHAR(150),
    "consultation_fee" DECIMAL(10,2),
    "status" "doctor_status" NOT NULL DEFAULT 'OFFLINE',
    "is_available_for_queue" BOOLEAN DEFAULT true,
    "is_bookable" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "doctors_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "doctor_schedules" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "doctor_id" UUID NOT NULL,
    "day_of_week" SMALLINT NOT NULL,
    "start_time" TIME(6) NOT NULL,
    "end_time" TIME(6) NOT NULL,
    "slot_duration_minutes" INTEGER DEFAULT 15,
    "max_patients" INTEGER,
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "doctor_schedules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "doctor_schedule_exceptions" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "doctor_id" UUID NOT NULL,
    "exception_date" DATE NOT NULL,
    "start_time" TIME(6),
    "end_time" TIME(6),
    "exception_type" "schedule_exception_type" NOT NULL,
    "reason" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "doctor_schedule_exceptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "hospitals" (
    "id" UUID NOT NULL,
    "name" VARCHAR(150) NOT NULL,
    "logo_url" TEXT,
    "address" TEXT,
    "contact_number" VARCHAR(30),
    "timezone" VARCHAR(80) DEFAULT 'Asia/Dhaka',
    "working_hours" JSONB,
    "token_settings" JSONB,
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "hospitals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "departments" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "code" VARCHAR(20) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rooms" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "room_number" VARCHAR(50) NOT NULL,
    "floor" VARCHAR(50),
    "description" TEXT,
    "is_active" BOOLEAN DEFAULT true,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "patient_id" UUID,
    "appointment_id" UUID,
    "queue_token_id" UUID,
    "channel" "notification_channel" NOT NULL,
    "notification_type" VARCHAR(50) NOT NULL,
    "recipient" VARCHAR(100) NOT NULL,
    "message" TEXT NOT NULL,
    "status" "notification_status" NOT NULL DEFAULT 'PENDING',
    "provider_response" JSONB,
    "scheduled_at" TIMESTAMP(6),
    "sent_at" TIMESTAMP(6),
    "failed_at" TIMESTAMP(6),
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sms_logs" (
    "id" UUID NOT NULL,
    "notification_id" UUID,
    "hospital_id" UUID NOT NULL,
    "provider_name" VARCHAR(80),
    "provider_message_id" VARCHAR(150),
    "phone" VARCHAR(30),
    "status" VARCHAR(30),
    "error_message" TEXT,
    "raw_response" JSONB,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "sms_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "patients" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "patient_code" VARCHAR(50) NOT NULL,
    "full_name" VARCHAR(150) NOT NULL,
    "phone" VARCHAR(30) NOT NULL,
    "normalized_phone" VARCHAR(30) NOT NULL,
    "age" INTEGER,
    "gender" "gender_type",
    "date_of_birth" DATE,
    "address" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "patients_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "patient_visits" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "patient_id" UUID NOT NULL,
    "department_id" UUID,
    "doctor_id" UUID,
    "visit_date" DATE NOT NULL,
    "visit_type" "visit_type" NOT NULL DEFAULT 'QUEUE',
    "notes" TEXT,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "patient_visits_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "queue_daily_counters" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "department_id" UUID,
    "doctor_id" UUID,
    "queue_date" DATE NOT NULL,
    "prefix" VARCHAR(20) NOT NULL,
    "last_sequence" INTEGER DEFAULT 0,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "queue_daily_counters_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "queue_tokens" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "patient_id" UUID NOT NULL,
    "visit_id" UUID,
    "appointment_id" UUID,
    "department_id" UUID NOT NULL,
    "doctor_id" UUID,
    "queue_date" DATE NOT NULL,
    "token_prefix" VARCHAR(20) NOT NULL,
    "token_sequence" INTEGER NOT NULL,
    "token_number" VARCHAR(50) NOT NULL,
    "status" "queue_status" NOT NULL DEFAULT 'WAITING',
    "priority_level" "priority_level" NOT NULL DEFAULT 'NORMAL',
    "queue_position" INTEGER,
    "created_by" UUID,
    "called_by" UUID,
    "completed_by" UUID,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "called_at" TIMESTAMP(6),
    "started_at" TIMESTAMP(6),
    "completed_at" TIMESTAMP(6),
    "skipped_at" TIMESTAMP(6),
    "cancelled_at" TIMESTAMP(6),
    "cancellation_reason" TEXT,
    "notes" TEXT,

    CONSTRAINT "queue_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "queue_token_events" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "queue_token_id" UUID NOT NULL,
    "old_status" "queue_status",
    "new_status" "queue_status" NOT NULL,
    "action" VARCHAR(80) NOT NULL,
    "performed_by" UUID,
    "metadata" JSONB,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "queue_token_events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "daily_queue_stats" (
    "id" UUID NOT NULL,
    "hospital_id" UUID NOT NULL,
    "department_id" UUID,
    "doctor_id" UUID,
    "report_date" DATE NOT NULL,
    "total_tokens" INTEGER DEFAULT 0,
    "completed_tokens" INTEGER DEFAULT 0,
    "cancelled_tokens" INTEGER DEFAULT 0,
    "skipped_tokens" INTEGER DEFAULT 0,
    "emergency_tokens" INTEGER DEFAULT 0,
    "avg_waiting_seconds" INTEGER DEFAULT 0,
    "avg_consultation_seconds" INTEGER DEFAULT 0,
    "created_at" TIMESTAMP(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(6) NOT NULL,

    CONSTRAINT "daily_queue_stats_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "appointments_hospital_id_doctor_id_appointment_date_idx" ON "appointments"("hospital_id", "doctor_id", "appointment_date");

-- CreateIndex
CREATE INDEX "appointments_hospital_id_patient_id_idx" ON "appointments"("hospital_id", "patient_id");

-- CreateIndex
CREATE INDEX "appointments_hospital_id_status_appointment_date_idx" ON "appointments"("hospital_id", "status", "appointment_date");

-- CreateIndex
CREATE UNIQUE INDEX "appointments_doctor_id_appointment_date_start_time_key" ON "appointments"("doctor_id", "appointment_date", "start_time");

-- CreateIndex
CREATE INDEX "audit_logs_hospital_id_created_at_idx" ON "audit_logs"("hospital_id", "created_at");

-- CreateIndex
CREATE INDEX "audit_logs_resource_type_resource_id_idx" ON "audit_logs"("resource_type", "resource_id");

-- CreateIndex
CREATE INDEX "audit_logs_user_id_idx" ON "audit_logs"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_hospital_id_idx" ON "users"("hospital_id");

-- CreateIndex
CREATE INDEX "users_email_idx" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_phone_idx" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "roles_code_key" ON "roles"("code");

-- CreateIndex
CREATE UNIQUE INDEX "permissions_code_key" ON "permissions"("code");

-- CreateIndex
CREATE INDEX "user_roles_user_id_idx" ON "user_roles"("user_id");

-- CreateIndex
CREATE INDEX "user_roles_role_id_idx" ON "user_roles"("role_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_roles_user_id_role_id_key" ON "user_roles"("user_id", "role_id");

-- CreateIndex
CREATE INDEX "role_permissions_role_id_idx" ON "role_permissions"("role_id");

-- CreateIndex
CREATE INDEX "role_permissions_permission_id_idx" ON "role_permissions"("permission_id");

-- CreateIndex
CREATE UNIQUE INDEX "role_permissions_role_id_permission_id_key" ON "role_permissions"("role_id", "permission_id");

-- CreateIndex
CREATE UNIQUE INDEX "doctors_user_id_key" ON "doctors"("user_id");

-- CreateIndex
CREATE INDEX "doctors_hospital_id_department_id_idx" ON "doctors"("hospital_id", "department_id");

-- CreateIndex
CREATE INDEX "doctors_hospital_id_status_idx" ON "doctors"("hospital_id", "status");

-- CreateIndex
CREATE INDEX "doctors_user_id_idx" ON "doctors"("user_id");

-- CreateIndex
CREATE INDEX "doctors_room_id_idx" ON "doctors"("room_id");

-- CreateIndex
CREATE INDEX "doctor_schedules_hospital_id_doctor_id_day_of_week_idx" ON "doctor_schedules"("hospital_id", "doctor_id", "day_of_week");

-- CreateIndex
CREATE INDEX "doctor_schedules_doctor_id_idx" ON "doctor_schedules"("doctor_id");

-- CreateIndex
CREATE INDEX "doctor_schedule_exceptions_hospital_id_doctor_id_exception__idx" ON "doctor_schedule_exceptions"("hospital_id", "doctor_id", "exception_date");

-- CreateIndex
CREATE UNIQUE INDEX "doctor_schedule_exceptions_doctor_id_exception_date_excepti_key" ON "doctor_schedule_exceptions"("doctor_id", "exception_date", "exception_type");

-- CreateIndex
CREATE INDEX "departments_hospital_id_idx" ON "departments"("hospital_id");

-- CreateIndex
CREATE UNIQUE INDEX "departments_hospital_id_code_key" ON "departments"("hospital_id", "code");

-- CreateIndex
CREATE UNIQUE INDEX "departments_hospital_id_name_key" ON "departments"("hospital_id", "name");

-- CreateIndex
CREATE INDEX "rooms_hospital_id_idx" ON "rooms"("hospital_id");

-- CreateIndex
CREATE UNIQUE INDEX "rooms_hospital_id_room_number_key" ON "rooms"("hospital_id", "room_number");

-- CreateIndex
CREATE INDEX "notifications_hospital_id_status_scheduled_at_idx" ON "notifications"("hospital_id", "status", "scheduled_at");

-- CreateIndex
CREATE INDEX "notifications_patient_id_idx" ON "notifications"("patient_id");

-- CreateIndex
CREATE INDEX "notifications_appointment_id_idx" ON "notifications"("appointment_id");

-- CreateIndex
CREATE INDEX "notifications_queue_token_id_idx" ON "notifications"("queue_token_id");

-- CreateIndex
CREATE INDEX "sms_logs_notification_id_idx" ON "sms_logs"("notification_id");

-- CreateIndex
CREATE INDEX "sms_logs_hospital_id_created_at_idx" ON "sms_logs"("hospital_id", "created_at");

-- CreateIndex
CREATE INDEX "sms_logs_provider_message_id_idx" ON "sms_logs"("provider_message_id");

-- CreateIndex
CREATE INDEX "patients_hospital_id_full_name_idx" ON "patients"("hospital_id", "full_name");

-- CreateIndex
CREATE INDEX "patients_hospital_id_idx" ON "patients"("hospital_id");

-- CreateIndex
CREATE UNIQUE INDEX "patients_hospital_id_patient_code_key" ON "patients"("hospital_id", "patient_code");

-- CreateIndex
CREATE UNIQUE INDEX "patients_hospital_id_normalized_phone_key" ON "patients"("hospital_id", "normalized_phone");

-- CreateIndex
CREATE INDEX "patient_visits_hospital_id_patient_id_idx" ON "patient_visits"("hospital_id", "patient_id");

-- CreateIndex
CREATE INDEX "patient_visits_hospital_id_visit_date_idx" ON "patient_visits"("hospital_id", "visit_date");

-- CreateIndex
CREATE INDEX "patient_visits_department_id_idx" ON "patient_visits"("department_id");

-- CreateIndex
CREATE INDEX "patient_visits_doctor_id_idx" ON "patient_visits"("doctor_id");

-- CreateIndex
CREATE INDEX "queue_daily_counters_hospital_id_queue_date_idx" ON "queue_daily_counters"("hospital_id", "queue_date");

-- CreateIndex
CREATE UNIQUE INDEX "queue_daily_counters_hospital_id_department_id_doctor_id_qu_key" ON "queue_daily_counters"("hospital_id", "department_id", "doctor_id", "queue_date");

-- CreateIndex
CREATE INDEX "queue_tokens_hospital_id_doctor_id_queue_date_priority_leve_idx" ON "queue_tokens"("hospital_id", "doctor_id", "queue_date", "priority_level", "created_at");

-- CreateIndex
CREATE INDEX "queue_tokens_hospital_id_department_id_queue_date_priority__idx" ON "queue_tokens"("hospital_id", "department_id", "queue_date", "priority_level", "created_at");

-- CreateIndex
CREATE INDEX "queue_tokens_hospital_id_queue_date_status_idx" ON "queue_tokens"("hospital_id", "queue_date", "status");

-- CreateIndex
CREATE INDEX "queue_tokens_hospital_id_patient_id_queue_date_idx" ON "queue_tokens"("hospital_id", "patient_id", "queue_date");

-- CreateIndex
CREATE INDEX "queue_tokens_appointment_id_idx" ON "queue_tokens"("appointment_id");

-- CreateIndex
CREATE INDEX "queue_tokens_visit_id_idx" ON "queue_tokens"("visit_id");

-- CreateIndex
CREATE UNIQUE INDEX "queue_tokens_hospital_id_queue_date_token_number_key" ON "queue_tokens"("hospital_id", "queue_date", "token_number");

-- CreateIndex
CREATE INDEX "queue_token_events_queue_token_id_created_at_idx" ON "queue_token_events"("queue_token_id", "created_at");

-- CreateIndex
CREATE INDEX "queue_token_events_hospital_id_created_at_idx" ON "queue_token_events"("hospital_id", "created_at");

-- CreateIndex
CREATE INDEX "queue_token_events_performed_by_idx" ON "queue_token_events"("performed_by");

-- CreateIndex
CREATE INDEX "daily_queue_stats_hospital_id_report_date_idx" ON "daily_queue_stats"("hospital_id", "report_date");

-- CreateIndex
CREATE UNIQUE INDEX "daily_queue_stats_hospital_id_department_id_doctor_id_repor_key" ON "daily_queue_stats"("hospital_id", "department_id", "doctor_id", "report_date");

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_doctor_id_fkey" FOREIGN KEY ("doctor_id") REFERENCES "doctors"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "appointments" ADD CONSTRAINT "appointments_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "audit_logs" ADD CONSTRAINT "audit_logs_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_roles" ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "roles"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "role_permissions" ADD CONSTRAINT "role_permissions_permission_id_fkey" FOREIGN KEY ("permission_id") REFERENCES "permissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctors" ADD CONSTRAINT "doctors_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctors" ADD CONSTRAINT "doctors_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctors" ADD CONSTRAINT "doctors_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctors" ADD CONSTRAINT "doctors_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctor_schedules" ADD CONSTRAINT "doctor_schedules_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctor_schedules" ADD CONSTRAINT "doctor_schedules_doctor_id_fkey" FOREIGN KEY ("doctor_id") REFERENCES "doctors"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctor_schedule_exceptions" ADD CONSTRAINT "doctor_schedule_exceptions_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "doctor_schedule_exceptions" ADD CONSTRAINT "doctor_schedule_exceptions_doctor_id_fkey" FOREIGN KEY ("doctor_id") REFERENCES "doctors"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "departments" ADD CONSTRAINT "departments_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_appointment_id_fkey" FOREIGN KEY ("appointment_id") REFERENCES "appointments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_queue_token_id_fkey" FOREIGN KEY ("queue_token_id") REFERENCES "queue_tokens"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sms_logs" ADD CONSTRAINT "sms_logs_notification_id_fkey" FOREIGN KEY ("notification_id") REFERENCES "notifications"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sms_logs" ADD CONSTRAINT "sms_logs_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "patients" ADD CONSTRAINT "patients_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "patient_visits" ADD CONSTRAINT "patient_visits_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "patient_visits" ADD CONSTRAINT "patient_visits_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "patient_visits" ADD CONSTRAINT "patient_visits_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "patient_visits" ADD CONSTRAINT "patient_visits_doctor_id_fkey" FOREIGN KEY ("doctor_id") REFERENCES "doctors"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_daily_counters" ADD CONSTRAINT "queue_daily_counters_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_daily_counters" ADD CONSTRAINT "queue_daily_counters_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_daily_counters" ADD CONSTRAINT "queue_daily_counters_doctor_id_fkey" FOREIGN KEY ("doctor_id") REFERENCES "doctors"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_patient_id_fkey" FOREIGN KEY ("patient_id") REFERENCES "patients"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_visit_id_fkey" FOREIGN KEY ("visit_id") REFERENCES "patient_visits"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_appointment_id_fkey" FOREIGN KEY ("appointment_id") REFERENCES "appointments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_doctor_id_fkey" FOREIGN KEY ("doctor_id") REFERENCES "doctors"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_called_by_fkey" FOREIGN KEY ("called_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_tokens" ADD CONSTRAINT "queue_tokens_completed_by_fkey" FOREIGN KEY ("completed_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_token_events" ADD CONSTRAINT "queue_token_events_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_token_events" ADD CONSTRAINT "queue_token_events_queue_token_id_fkey" FOREIGN KEY ("queue_token_id") REFERENCES "queue_tokens"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "queue_token_events" ADD CONSTRAINT "queue_token_events_performed_by_fkey" FOREIGN KEY ("performed_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_queue_stats" ADD CONSTRAINT "daily_queue_stats_hospital_id_fkey" FOREIGN KEY ("hospital_id") REFERENCES "hospitals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_queue_stats" ADD CONSTRAINT "daily_queue_stats_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "daily_queue_stats" ADD CONSTRAINT "daily_queue_stats_doctor_id_fkey" FOREIGN KEY ("doctor_id") REFERENCES "doctors"("id") ON DELETE SET NULL ON UPDATE CASCADE;
