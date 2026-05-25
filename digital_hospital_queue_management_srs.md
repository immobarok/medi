# Software Requirements Specification (SRS)

# Digital Hospital Queue Management System

**Version:** 1.0  
**Prepared For:** Hospital / Clinic Queue Digitization  
**Target Region:** Bangladesh  
**Document Type:** Software Requirements Specification  
**Deployment Model:** Single Hospital Deployment for MVP  

---

## Document Control

| Item | Details |
|---|---|
| Document Name | Digital Hospital Queue Management System SRS |
| Version | 1.0 |
| Status | Draft / Initial Specification |
| Primary Users | Receptionists, Doctors, Hospital Admins, Super Admins, Nurses |
| Core Objective | Realtime digital queue, token, and appointment management for hospitals and clinics |

---

## Table of Contents

1. Introduction  
2. Product Overview  
3. Stakeholders and User Roles  
4. End-to-End System Flow  
5. Functional Requirements  
6. Queue Management Requirements  
7. Realtime System Requirements  
8. Dashboard Requirements  
9. Notification Requirements  
10. Reporting and Analytics Requirements  
11. Audit Log Requirements  
12. Non-Functional Requirements  
13. System Architecture  
14. Database Requirements  
15. API Requirements  
16. Error Handling Requirements  
17. Deployment Requirements  
18. Development Phases  
19. Future Enhancements  
20. Success Criteria  
21. Conclusion  

---

# 1. Introduction

## 1.1 Purpose

The purpose of the Digital Hospital Queue Management System is to provide a realtime, structured, and low-friction queue and appointment management platform for hospitals and clinics in Bangladesh.

The system will digitize patient token handling, reduce manual queue coordination, improve doctor-patient flow, and provide realtime visibility across reception desks, doctor dashboards, and waiting-room display screens.

The system is designed to support a smooth operational workflow for:

- Receptionists
- Doctors
- Hospital administrators
- Super administrators
- Nurses or assistant staff
- Patients

## 1.2 Business Problem

Many hospitals and clinics still depend on manual queue handling, verbal announcements, paper-based tokens, and fragmented appointment tracking. This creates several operational issues:

- Patients do not know their real queue position.
- Receptionists must repeatedly answer queue-related questions.
- Doctors do not always receive a clear next-patient sequence.
- Manual token handling causes confusion, delays, and duplication.
- Hospital administrators lack reliable queue performance data.

This system solves these problems by introducing a centralized digital queue engine with realtime synchronization.

## 1.3 Scope

The MVP will support a single hospital or clinic deployment. It will provide the essential modules needed to manage patients, doctors, departments, queue tokens, appointments, realtime displays, and basic reporting.

The system will include:

- User authentication and role-based access control
- Hospital profile and settings management
- Department management
- Doctor profile and schedule management
- Patient registration and patient search
- Realtime token generation and queue control
- Appointment creation and queue conversion
- Waiting-room queue display screen
- SMS notification support
- Analytics and reporting
- Audit logging

Future versions may support:

- Multi-branch hospitals
- Multi-tenant SaaS deployment
- Mobile applications for patients and staff
- WhatsApp notifications
- QR-based token check-in
- AI-based waiting-time prediction

## 1.4 Objectives

The primary objectives of the system are:

- Eliminate manual queue handling where possible.
- Reduce patient confusion and unnecessary waiting-room pressure.
- Keep reception operations fast and low-click.
- Provide doctors with a clear and controlled patient flow.
- Keep all dashboards synchronized in realtime.
- Improve hospital operational efficiency.
- Create a scalable foundation for future multi-hospital support.

## 1.5 Definitions and Abbreviations

| Term | Meaning |
|---|---|
| SRS | Software Requirements Specification |
| RBAC | Role-Based Access Control |
| JWT | JSON Web Token |
| FIFO | First In, First Out queue algorithm |
| MVP | Minimum Viable Product |
| Token | Digital queue number assigned to a patient |
| Queue Display | Screen shown in the waiting area for patients |
| WebSocket | Realtime communication protocol |
| Redis Pub/Sub | Redis-based publish-subscribe mechanism for realtime updates |

---

# 2. Product Overview

## 2.1 Product Description

The Digital Hospital Queue Management System is a web-based application that allows hospitals and clinics to manage patient queues and appointments through a centralized platform.

The system will be used by receptionists to register patients and generate tokens, by doctors to call and complete patient consultations, by admins to configure hospital operations, and by patients through public queue displays or notifications.

The core operational principle is simple:

**Reception generates the token → Queue updates realtime → Doctor calls patient → Consultation completes → Queue advances.**

## 2.2 Product Positioning

The system is positioned as an operational tool for hospitals and clinics that need a practical, fast, and scalable alternative to manual token systems.

The product prioritizes:

- Speed
- Simplicity
- Realtime synchronization
- Low training requirement
- Operational reliability
- Future scalability

## 2.3 System Users

The main users of the system are:

- Super Admin
- Hospital Admin
- Receptionist
- Doctor
- Nurse or Assistant Staff
- Patient

Patients do not need full login access in the MVP. They will interact indirectly through SMS notifications, queue display screens, and optional future patient portals.

---

# 3. Stakeholders and User Roles

## 3.1 Stakeholders

| Stakeholder | Interest |
|---|---|
| Hospital Owner / Management | Operational efficiency, patient satisfaction, reporting |
| Hospital Admin | Staff, department, doctor, and schedule management |
| Receptionist | Fast patient registration and token handling |
| Doctor | Smooth patient flow and queue control |
| Nurse / Assistant | Support doctor and patient movement |
| Patient | Clear queue position and reduced confusion |
| Technical Admin | Deployment, security, backup, and monitoring |

## 3.2 User Roles and Responsibilities

| Role | Responsibilities |
|---|---|
| Super Admin | Full system access, hospital configuration, user management, global settings |
| Hospital Admin | Manage hospital profile, departments, doctors, schedules, and reports |
| Receptionist | Search/register patients, generate tokens, manage queue entries, handle appointments |
| Doctor | View current queue, call next patient, skip patient, recall patient, complete consultation |
| Nurse | Assist doctors, view patient queue, support patient movement |

## 3.3 Access Control Summary

| Module | Super Admin | Hospital Admin | Receptionist | Doctor | Nurse |
|---|---:|---:|---:|---:|---:|
| Authentication | Yes | Yes | Yes | Yes | Yes |
| Hospital Settings | Yes | Yes | No | No | No |
| Department Management | Yes | Yes | No | No | No |
| Doctor Management | Yes | Yes | No | Limited | No |
| Patient Management | Yes | Yes | Yes | Read | Read |
| Queue Management | Yes | Yes | Yes | Yes | Limited |
| Appointments | Yes | Yes | Yes | Read | Limited |
| Reports | Yes | Yes | Limited | Limited | No |
| Audit Logs | Yes | Yes | No | No | No |

---

# 4. End-to-End System Flow

## 4.1 Primary Patient Queue Flow

The queue flow must remain smooth, fast, and synchronized across all dashboards.

```text
Patient arrives at hospital/clinic
        ↓
Receptionist searches patient by phone number or patient ID
        ↓
If patient exists → existing patient profile is loaded
If patient does not exist → receptionist completes quick registration
        ↓
Receptionist selects department and/or doctor
        ↓
System generates queue token automatically
        ↓
Token status becomes WAITING
        ↓
Reception dashboard, doctor dashboard, and queue display update in realtime
        ↓
Doctor clicks “Call Next”
        ↓
Token status becomes CALLED
        ↓
Waiting-room display shows current token, doctor, and room
        ↓
Patient enters consultation room
        ↓
Doctor starts consultation
        ↓
Token status becomes IN_PROGRESS
        ↓
Doctor completes consultation
        ↓
Token status becomes COMPLETED
        ↓
System advances queue and updates all dashboards
```

## 4.2 Returning Patient Flow

```text
Patient arrives
        ↓
Receptionist searches phone number or patient ID
        ↓
System finds existing patient
        ↓
Receptionist verifies basic details
        ↓
Receptionist selects department or doctor
        ↓
System generates token
        ↓
Patient enters queue
```

## 4.3 New Patient Flow

```text
Patient arrives
        ↓
Receptionist searches phone number
        ↓
No patient record found
        ↓
Receptionist opens quick registration form
        ↓
Receptionist enters name, phone, age, and gender
        ↓
System creates patient profile
        ↓
Receptionist generates token
        ↓
Patient enters queue
```

## 4.4 Appointment-to-Queue Flow

```text
Appointment is created
        ↓
Patient arrives at hospital
        ↓
Receptionist confirms arrival
        ↓
System converts appointment into queue token
        ↓
Patient enters waiting queue
        ↓
Doctor calls patient
        ↓
Consultation completed
```

## 4.5 Doctor Consultation Flow

```text
Doctor opens dashboard
        ↓
Doctor sees current queue and next patient
        ↓
Doctor clicks “Call Next”
        ↓
System assigns next eligible token
        ↓
Patient is displayed on waiting-room screen
        ↓
Doctor starts consultation
        ↓
Doctor completes consultation
        ↓
Queue automatically moves to the next eligible patient
```

## 4.6 Emergency Priority Flow

```text
Receptionist marks patient as EMERGENCY
        ↓
System validates permission
        ↓
Emergency token receives highest priority
        ↓
Queue order is recalculated
        ↓
Doctor dashboard updates instantly
        ↓
Emergency patient is called before normal waiting tokens
```

---

# 5. Functional Requirements

## 5.1 Authentication and Authorization Module

### 5.1.1 Description

The system must provide secure login, logout, session handling, and role-based access control.

### 5.1.2 Functional Requirements

| ID | Requirement |
|---|---|
| FR-AUTH-001 | The system shall allow authorized users to log in using email and password. |
| FR-AUTH-002 | The system shall issue an access token after successful login. |
| FR-AUTH-003 | The system shall support refresh token-based session renewal. |
| FR-AUTH-004 | The system shall allow users to log out securely. |
| FR-AUTH-005 | The system shall provide password reset functionality. |
| FR-AUTH-006 | The system shall enforce role-based access control for all protected routes. |
| FR-AUTH-007 | The system shall validate permissions before allowing sensitive operations. |

### 5.1.3 Input Data

| Field | Type | Required |
|---|---|---|
| email | string | Yes |
| password | string | Yes |

### 5.1.4 Output Data

| Field | Type | Description |
|---|---|---|
| access_token | string | Token used for authenticated API requests |
| refresh_token | string | Token used to renew access sessions |
| user_role | string | Authenticated user role |
| permissions | array | User permission list |

---

## 5.2 Hospital Management Module

### 5.2.1 Description

The hospital management module allows administrators to configure hospital identity, operational settings, working hours, token rules, and general system behavior.

### 5.2.2 Functional Requirements

| ID | Requirement |
|---|---|
| FR-HOSP-001 | The system shall allow authorized admins to create a hospital profile. |
| FR-HOSP-002 | The system shall allow admins to update hospital information. |
| FR-HOSP-003 | The system shall allow configuration of hospital working hours. |
| FR-HOSP-004 | The system shall allow configuration of token format rules. |
| FR-HOSP-005 | The system shall allow enabling or disabling operational settings. |
| FR-HOSP-006 | The system shall store hospital contact and address information. |

### 5.2.3 Hospital Data Fields

| Field | Type | Required |
|---|---|---|
| hospital_name | string | Yes |
| logo | string | No |
| address | string | Yes |
| contact_number | string | Yes |
| working_hours | json | Yes |
| token_format | json | Yes |
| timezone | string | Yes |

---

## 5.3 Department Management Module

### 5.3.1 Description

Departments are used to organize doctors and queue tokens. Each department can have its own token prefix and queue behavior.

### 5.3.2 Functional Requirements

| ID | Requirement |
|---|---|
| FR-DEPT-001 | The system shall allow admins to create departments. |
| FR-DEPT-002 | The system shall allow admins to edit department details. |
| FR-DEPT-003 | The system shall allow admins to enable or disable departments. |
| FR-DEPT-004 | The system shall allow doctors to be assigned to departments. |
| FR-DEPT-005 | The system shall support department-based queue behavior. |
| FR-DEPT-006 | The system shall support department-specific token prefixes. |

### 5.3.3 Example Departments

- Medicine
- Cardiology
- Orthopedics
- ENT
- Dermatology

---

## 5.4 Doctor Management Module

### 5.4.1 Description

The doctor management module allows administrators to create doctor profiles, assign departments, define schedules, set room numbers, and control availability.

### 5.4.2 Functional Requirements

| ID | Requirement |
|---|---|
| FR-DOC-001 | The system shall allow admins to create doctor profiles. |
| FR-DOC-002 | The system shall allow doctors to be assigned to departments. |
| FR-DOC-003 | The system shall allow admins to define doctor schedules. |
| FR-DOC-004 | The system shall allow room numbers to be assigned to doctors. |
| FR-DOC-005 | The system shall allow doctors or admins to update doctor availability. |
| FR-DOC-006 | The system shall prevent tokens from being assigned to unavailable doctors where applicable. |
| FR-DOC-007 | The system shall allow doctor queue participation to be enabled or disabled. |

### 5.4.3 Doctor Data Fields

| Field | Type | Required |
|---|---|---|
| name | string | Yes |
| specialization | string | Yes |
| department_id | uuid | Yes |
| room_number | string | No |
| status | enum | Yes |
| schedule | json | No |

### 5.4.4 Doctor Status Types

| Status | Meaning |
|---|---|
| AVAILABLE | Doctor is available for queue handling |
| BUSY | Doctor is currently occupied |
| BREAK | Doctor is temporarily unavailable |
| OFFLINE | Doctor is not active in the system |

---

## 5.5 Patient Management Module

### 5.5.1 Description

The patient management module must support fast reception operations. Patient search and registration should be optimized for minimal typing and minimal clicks.

The target registration time for a new patient should be under 20 seconds.

### 5.5.2 Functional Requirements

| ID | Requirement |
|---|---|
| FR-PAT-001 | The system shall allow receptionists to search patients by phone number. |
| FR-PAT-002 | The system shall allow receptionists to search patients by patient ID. |
| FR-PAT-003 | The system shall show matching patient records quickly. |
| FR-PAT-004 | The system shall allow quick registration for new patients. |
| FR-PAT-005 | The system shall store basic patient information. |
| FR-PAT-006 | The system shall maintain patient visit history. |
| FR-PAT-007 | The system shall show previous appointments and queue records. |
| FR-PAT-008 | The system shall prevent duplicate patient creation where phone number or patient ID already exists. |

### 5.5.3 Quick Registration Fields

| Field | Type | Required |
|---|---|---|
| name | string | Yes |
| phone | string | Yes |
| age | number | No |
| gender | enum | No |

### 5.5.4 Reception Patient Search Flow

```text
Search phone number or patient ID
        ↓
If found → Load patient profile
If not found → Show quick registration option
        ↓
Select department or doctor
        ↓
Generate token
```

---

## 5.6 Appointment Management Module

### 5.6.1 Description

The appointment module allows receptionists or authorized users to create, reschedule, cancel, and manage patient appointments. On patient arrival, an appointment can be converted into a queue token.

### 5.6.2 Functional Requirements

| ID | Requirement |
|---|---|
| FR-APT-001 | The system shall allow appointments to be created. |
| FR-APT-002 | The system shall allow appointments to be rescheduled. |
| FR-APT-003 | The system shall allow appointments to be cancelled. |
| FR-APT-004 | The system shall support appointment reminders. |
| FR-APT-005 | The system shall allow confirmed appointments to be converted into queue tokens. |
| FR-APT-006 | The system shall prevent appointment conflicts for the same doctor and time slot. |
| FR-APT-007 | The system shall show appointments on the reception dashboard. |

### 5.6.3 Appointment Status Types

| Status | Meaning |
|---|---|
| SCHEDULED | Appointment has been booked |
| CONFIRMED | Patient or staff has confirmed the appointment |
| ARRIVED | Patient has arrived at hospital |
| CONVERTED_TO_QUEUE | Appointment has been converted into a queue token |
| CANCELLED | Appointment has been cancelled |
| COMPLETED | Appointment consultation has been completed |

---

# 6. Queue Management Requirements

## 6.1 Description

The Queue Management Module is the core module of the system. It controls token creation, queue order, doctor calling flow, skipped patients, cancelled tokens, emergency priority handling, and queue completion.

## 6.2 Queue Token Lifecycle

```text
Token Created
        ↓
WAITING
        ↓
CALLED
        ↓
IN_PROGRESS
        ↓
COMPLETED
```

Optional token states:

```text
SKIPPED
CANCELLED
EMERGENCY
```

## 6.3 Token Status Definitions

| Status | Description |
|---|---|
| WAITING | Token is waiting in queue |
| CALLED | Doctor has called the patient |
| IN_PROGRESS | Consultation has started |
| COMPLETED | Consultation has finished |
| SKIPPED | Patient was skipped temporarily |
| CANCELLED | Token was cancelled |
| EMERGENCY | Token has emergency priority |

## 6.4 Functional Requirements

| ID | Requirement |
|---|---|
| FR-QUE-001 | The system shall generate tokens automatically. |
| FR-QUE-002 | The system shall support department-based token generation. |
| FR-QUE-003 | The system shall support doctor-based queue assignment. |
| FR-QUE-004 | The system shall prevent duplicate active tokens for the same patient, department, and doctor where configured. |
| FR-QUE-005 | The system shall allow receptionists to create tokens. |
| FR-QUE-006 | The system shall allow receptionists to cancel tokens. |
| FR-QUE-007 | The system shall allow authorized users to assign priority levels. |
| FR-QUE-008 | The system shall allow doctors to call the next patient. |
| FR-QUE-009 | The system shall allow doctors to skip a patient. |
| FR-QUE-010 | The system shall allow doctors to recall a skipped or called patient. |
| FR-QUE-011 | The system shall allow doctors to complete consultations. |
| FR-QUE-012 | The system shall update all connected dashboards when a token changes. |
| FR-QUE-013 | The system shall maintain queue logs for every token state change. |

## 6.5 Token Format

The system shall support configurable token formats.

Examples:

| Department | Token Example |
|---|---|
| Medicine | MED-101 |
| ENT | ENT-205 |
| Cardiology | CAR-055 |

## 6.6 Queue Rules

| Rule | Description |
|---|---|
| FIFO | Normal patients are called in token creation order. |
| Priority Override | Priority and emergency patients may be moved ahead based on configuration. |
| Skipped Token Handling | Skipped tokens remain available for recall or re-entry into queue. |
| Doctor Availability | Queue cannot assign patients to offline doctors unless manually overridden. |
| Maximum Queue Limit | The system may restrict token generation when queue capacity is reached. |
| Duplicate Prevention | The system must prevent accidental duplicate active tokens. |

## 6.7 Queue Priority Levels

| Level | Description | Queue Impact |
|---|---|---|
| NORMAL | Standard patient | Follows FIFO order |
| PRIORITY | Elderly, urgent, or special-care patient | Can move ahead of normal tokens |
| EMERGENCY | Critical patient | Highest priority and immediate attention |

## 6.8 Queue Algorithm

The default queue algorithm shall be FIFO.

Priority calculation shall follow this order:

1. Emergency tokens
2. Priority tokens
3. Normal tokens by creation time
4. Skipped tokens based on configured re-entry rule

## 6.9 Queue Operation Acceptance Criteria

- Token creation must complete quickly from the reception dashboard.
- Calling the next patient must require one primary action from the doctor dashboard.
- Queue state changes must be reflected on all dashboards within one second under normal conditions.
- Completed consultations must no longer appear in the active queue.
- Cancelled tokens must be excluded from active queue flow but retained in logs.

---

# 7. Realtime System Requirements

## 7.1 Description

The system must provide realtime synchronization across reception dashboards, doctor dashboards, waiting-room queue displays, and administrative views.

Users must not need to manually refresh the page to see queue updates.

## 7.2 Realtime Components

| Component | Realtime Data |
|---|---|
| Reception Dashboard | Token creation, cancellation, queue status, appointment arrival |
| Doctor Dashboard | Current patient, next patient, queue updates, skipped tokens |
| Queue Display Screen | Now serving token, next token, doctor name, room number |
| Admin Dashboard | Queue load, active doctors, completed consultations |

## 7.3 Realtime Events

| Event | Description |
|---|---|
| queue.updated | Queue has been modified |
| token.created | New token has been generated |
| token.called | Doctor has called a token |
| token.skipped | Doctor has skipped a token |
| token.completed | Consultation has been completed |
| token.cancelled | Token has been cancelled |
| doctor.status.changed | Doctor availability has changed |
| appointment.arrived | Appointment patient has arrived |

## 7.4 Technology Requirements

The realtime layer should use:

- WebSocket
- Socket.IO
- Redis Pub/Sub

## 7.5 Realtime Reliability Requirements

| ID | Requirement |
|---|---|
| NFR-RT-001 | The system shall reconnect automatically after websocket disconnection. |
| NFR-RT-002 | The system shall recover latest queue state after reconnection. |
| NFR-RT-003 | The system shall persist queue updates in the database before broadcasting events. |
| NFR-RT-004 | The system shall support Redis Pub/Sub for scalable event distribution. |
| NFR-RT-005 | The system shall provide fallback polling if realtime connection fails repeatedly. |

---

# 8. Dashboard Requirements

## 8.1 Reception Dashboard

### Description

The reception dashboard is the highest-frequency operational screen. It must be optimized for speed, clarity, and minimal clicks.

### Required Features

| ID | Requirement |
|---|---|
| FR-DASH-REC-001 | Receptionists shall be able to search patients from the main dashboard. |
| FR-DASH-REC-002 | Receptionists shall be able to quickly register new patients. |
| FR-DASH-REC-003 | Receptionists shall be able to generate queue tokens from one screen. |
| FR-DASH-REC-004 | Receptionists shall be able to view active queue status. |
| FR-DASH-REC-005 | Receptionists shall be able to view today’s appointments. |
| FR-DASH-REC-006 | Receptionists shall be able to cancel or reschedule tokens where permitted. |
| FR-DASH-REC-007 | The reception dashboard shall update queue information in realtime. |

### Reception Dashboard Layout Requirement

The following should be available on one screen:

- Patient search
- Quick registration
- Department/doctor selection
- Generate token button
- Active queue overview
- Appointment list
- Token status panel

## 8.2 Doctor Dashboard

### Description

The doctor dashboard must be simple and focused. Doctors should be able to manage consultations with minimal interaction.

### Required Features

| ID | Requirement |
|---|---|
| FR-DASH-DOC-001 | Doctors shall see the current patient. |
| FR-DASH-DOC-002 | Doctors shall see the next waiting patient. |
| FR-DASH-DOC-003 | Doctors shall be able to call the next patient. |
| FR-DASH-DOC-004 | Doctors shall be able to skip a patient. |
| FR-DASH-DOC-005 | Doctors shall be able to recall a patient. |
| FR-DASH-DOC-006 | Doctors shall be able to mark consultation as completed. |
| FR-DASH-DOC-007 | Doctors shall be able to update their availability status. |

### Doctor Dashboard Main Actions

```text
Call Next
Skip
Recall
Start Consultation
Complete Consultation
```

## 8.3 Queue Display Dashboard

### Description

The queue display dashboard will be shown on waiting-room screens. It must be readable from a distance and update automatically.

### Display Content

```text
NOW SERVING: MED-101
NEXT TOKEN: MED-102
DOCTOR: Dr. Hasan
ROOM: 203
```

### Required Features

| ID | Requirement |
|---|---|
| FR-DASH-DIS-001 | The queue display shall show the currently serving token. |
| FR-DASH-DIS-002 | The queue display shall show the next token. |
| FR-DASH-DIS-003 | The queue display shall show doctor name and room number. |
| FR-DASH-DIS-004 | The queue display shall support fullscreen mode. |
| FR-DASH-DIS-005 | The queue display shall update in realtime. |
| FR-DASH-DIS-006 | The queue display should support multiple display screens. |
| FR-DASH-DIS-007 | The queue display may support optional voice announcements. |

---

# 9. Notification Requirements

## 9.1 Description

The notification module will notify patients about token creation, appointment reminders, and queue proximity alerts.

The initial supported channel shall be SMS.

## 9.2 SMS Notification Types

| Notification | Description |
|---|---|
| Token Confirmation | Sent when a token is generated |
| Appointment Reminder | Sent before appointment time |
| Queue Near Alert | Sent when patient’s queue position is near |

## 9.3 Notification Triggers

| Trigger | Notification Type |
|---|---|
| token_created | SMS token confirmation |
| queue_position_near | SMS queue near alert |
| appointment_reminder | SMS appointment reminder |
| appointment_rescheduled | SMS appointment update |
| appointment_cancelled | SMS cancellation notice |

## 9.4 Functional Requirements

| ID | Requirement |
|---|---|
| FR-NOT-001 | The system shall send SMS when a token is created if SMS is enabled. |
| FR-NOT-002 | The system shall send appointment reminders based on configured timing. |
| FR-NOT-003 | The system shall send queue near alerts when a patient is close to being called. |
| FR-NOT-004 | The system shall log all notification attempts. |
| FR-NOT-005 | The system shall record SMS delivery status where supported by provider. |
| FR-NOT-006 | The system shall support enabling or disabling notification types. |

---

# 10. Reporting and Analytics Requirements

## 10.1 Description

The reporting module provides administrators with operational visibility into patient volume, queue performance, doctor activity, and department load.

## 10.2 Dashboard Metrics

| Metric | Description |
|---|---|
| Total Patients | Number of registered patients |
| Daily Patient Count | Number of patients served today |
| Average Waiting Time | Average time from token creation to doctor call |
| Active Doctors | Number of available doctors |
| Completed Consultations | Number of completed consultations |
| Queue Load | Current active queue volume |
| Department Load | Queue volume by department |

## 10.3 Reports

### Daily Reports

- Patient count
- Token count
- Completed consultations
- Cancelled tokens
- Skipped tokens
- Average waiting time

### Monthly Reports

- Doctor performance
- Department load
- Patient volume trends
- Queue efficiency
- Peak hour analysis

## 10.4 Functional Requirements

| ID | Requirement |
|---|---|
| FR-REP-001 | The system shall show daily queue statistics. |
| FR-REP-002 | The system shall show monthly queue statistics. |
| FR-REP-003 | The system shall show doctor-wise consultation counts. |
| FR-REP-004 | The system shall show department-wise queue load. |
| FR-REP-005 | The system shall calculate average waiting time. |
| FR-REP-006 | The system shall allow reports to be filtered by date range. |

---

# 11. Audit Log Requirements

## 11.1 Description

The audit log module records important system actions for accountability and troubleshooting.

## 11.2 Audit Events

The system shall track:

- User login and logout
- Token creation
- Token cancellation
- Token status changes
- Appointment creation
- Appointment changes
- Doctor status changes
- Admin configuration changes
- Permission-sensitive operations

## 11.3 Functional Requirements

| ID | Requirement |
|---|---|
| FR-AUD-001 | The system shall log user authentication events. |
| FR-AUD-002 | The system shall log token state changes. |
| FR-AUD-003 | The system shall log appointment changes. |
| FR-AUD-004 | The system shall log admin operations. |
| FR-AUD-005 | Audit logs shall include user ID, action, timestamp, and target resource. |
| FR-AUD-006 | Audit logs shall be viewable only by authorized admins. |

---

# 12. Non-Functional Requirements

## 12.1 Performance Requirements

| ID | Requirement | Target |
|---|---|---|
| NFR-PERF-001 | API response time for standard requests | Less than 500ms |
| NFR-PERF-002 | Queue update delay | Less than 1 second |
| NFR-PERF-003 | Concurrent user support | 500+ users |
| NFR-PERF-004 | Patient search response | Less than 1 second |
| NFR-PERF-005 | Token generation time | Less than 2 seconds |

## 12.2 Scalability Requirements

| ID | Requirement |
|---|---|
| NFR-SCA-001 | The system shall support multiple departments. |
| NFR-SCA-002 | The system shall support multiple doctors. |
| NFR-SCA-003 | The system architecture shall allow future multi-hospital support. |
| NFR-SCA-004 | The realtime layer shall support horizontal scaling through Redis Pub/Sub. |

## 12.3 Reliability Requirements

| ID | Requirement |
|---|---|
| NFR-REL-001 | The system shall persist all queue state changes. |
| NFR-REL-002 | The system shall support automatic websocket reconnection. |
| NFR-REL-003 | The system shall recover active queue state after server restart. |
| NFR-REL-004 | The system shall support scheduled database backups. |
| NFR-REL-005 | The system shall continue core operations if notification service fails. |

## 12.4 Security Requirements

| ID | Requirement |
|---|---|
| NFR-SEC-001 | Passwords shall be securely hashed. |
| NFR-SEC-002 | Authentication shall use JWT or equivalent secure token mechanism. |
| NFR-SEC-003 | The system shall enforce HTTPS in production. |
| NFR-SEC-004 | The system shall enforce RBAC authorization. |
| NFR-SEC-005 | APIs shall validate all inputs. |
| NFR-SEC-006 | The system shall implement rate limiting on sensitive endpoints. |
| NFR-SEC-007 | The system shall protect patient information from unauthorized access. |
| NFR-SEC-008 | Refresh tokens shall be stored and invalidated securely. |

## 12.5 Usability Requirements

| ID | Requirement |
|---|---|
| NFR-USE-001 | Reception workflow shall require minimal typing. |
| NFR-USE-002 | Token operations should remain under two clicks where possible. |
| NFR-USE-003 | Interfaces shall be usable on low-end devices. |
| NFR-USE-004 | The system shall remain usable on poor or unstable internet connections. |
| NFR-USE-005 | Queue display text shall be readable from a reasonable waiting-room distance. |
| NFR-USE-006 | Staff users shall require minimal training to operate core features. |

## 12.6 Maintainability Requirements

| ID | Requirement |
|---|---|
| NFR-MNT-001 | Backend code shall follow modular architecture. |
| NFR-MNT-002 | API endpoints shall follow consistent naming conventions. |
| NFR-MNT-003 | Queue logic shall be isolated into a maintainable service layer. |
| NFR-MNT-004 | Configuration values shall be managed through environment variables. |
| NFR-MNT-005 | The system shall maintain structured logs for troubleshooting. |

---

# 13. System Architecture

## 13.1 High-Level Architecture

```text
Frontend Dashboard
        |
REST API + WebSocket Gateway
        |
NestJS Backend
        |
--------------------------------
| PostgreSQL Database          |
| Redis Pub/Sub and Cache      |
| BullMQ Background Workers    |
--------------------------------
        |
SMS Notification Service
```

## 13.2 Recommended Technology Stack

| Layer | Technology |
|---|---|
| Frontend | React / Next.js or equivalent web framework |
| Backend | NestJS |
| Database | PostgreSQL |
| Realtime | WebSocket / Socket.IO |
| Queue / Jobs | BullMQ |
| Cache / PubSub | Redis |
| Deployment | Docker on Ubuntu VPS |
| Notifications | SMS provider integration |

## 13.3 Architecture Principles

- API-first backend design
- Modular service-based backend structure
- Realtime-first queue updates
- Database-backed queue persistence
- Redis-supported event distribution
- Dockerized deployment
- Future-ready multi-hospital architecture

---

# 14. Database Requirements

## 14.1 Core Database Tables

### Authentication Tables

```text
users
roles
permissions
sessions
```

### Hospital Tables

```text
hospitals
departments
hospital_settings
```

### Medical Operation Tables

```text
doctors
patients
appointments
```

### Queue Tables

```text
queues
queue_tokens
queue_logs
```

### Notification Tables

```text
notifications
sms_logs
```

### Audit Tables

```text
audit_logs
```

## 14.2 Key Entity Relationships

- A hospital has many departments.
- A department has many doctors.
- A doctor belongs to one or more schedules.
- A patient can have many appointments.
- A patient can have many queue tokens.
- A queue token belongs to one patient.
- A queue token may belong to one department and one doctor.
- Queue logs belong to queue tokens.
- SMS logs belong to notifications or token events.

## 14.3 Queue Token Suggested Fields

| Field | Type | Description |
|---|---|---|
| id | uuid | Unique token ID |
| token_number | string | Human-readable token number |
| patient_id | uuid | Patient reference |
| department_id | uuid | Department reference |
| doctor_id | uuid | Doctor reference |
| status | enum | Current token status |
| priority_level | enum | NORMAL, PRIORITY, or EMERGENCY |
| created_at | timestamp | Token creation time |
| called_at | timestamp | Time patient was called |
| completed_at | timestamp | Consultation completion time |
| cancelled_at | timestamp | Cancellation time |

---

# 15. API Requirements

## 15.1 Authentication APIs

| Method | Endpoint | Description |
|---|---|---|
| POST | /auth/login | User login |
| POST | /auth/refresh | Refresh access token |
| POST | /auth/logout | User logout |
| POST | /auth/password-reset | Request password reset |

## 15.2 Patient APIs

| Method | Endpoint | Description |
|---|---|---|
| POST | /patients | Create patient |
| GET | /patients | Search/list patients |
| GET | /patients/:id | Get patient details |
| PATCH | /patients/:id | Update patient details |

## 15.3 Queue APIs

| Method | Endpoint | Description |
|---|---|---|
| POST | /queues/token | Create queue token |
| GET | /queues/active | Get active queue |
| PATCH | /queues/next | Call next patient |
| PATCH | /queues/skip | Skip patient |
| PATCH | /queues/recall | Recall patient |
| PATCH | /queues/complete | Complete consultation |
| PATCH | /queues/cancel | Cancel token |

## 15.4 Appointment APIs

| Method | Endpoint | Description |
|---|---|---|
| POST | /appointments | Create appointment |
| GET | /appointments | List/search appointments |
| GET | /appointments/:id | Get appointment details |
| PATCH | /appointments/:id | Update or reschedule appointment |
| DELETE | /appointments/:id | Cancel appointment |
| POST | /appointments/:id/convert-to-token | Convert appointment to queue token |

## 15.5 Doctor APIs

| Method | Endpoint | Description |
|---|---|---|
| POST | /doctors | Create doctor |
| GET | /doctors | List doctors |
| GET | /doctors/:id | Get doctor details |
| PATCH | /doctors/:id | Update doctor |
| PATCH | /doctors/:id/status | Update doctor status |

## 15.6 Department APIs

| Method | Endpoint | Description |
|---|---|---|
| POST | /departments | Create department |
| GET | /departments | List departments |
| PATCH | /departments/:id | Update department |
| PATCH | /departments/:id/status | Enable or disable department |

## 15.7 Report APIs

| Method | Endpoint | Description |
|---|---|---|
| GET | /reports/dashboard | Dashboard summary metrics |
| GET | /reports/daily | Daily report |
| GET | /reports/monthly | Monthly report |
| GET | /reports/doctors | Doctor performance report |
| GET | /reports/departments | Department load report |

---

# 16. Error Handling Requirements

## 16.1 System Errors to Handle

The system must handle the following error scenarios:

- WebSocket disconnection
- Duplicate token creation
- Doctor offline state
- Appointment scheduling conflicts
- Redis downtime
- SMS provider failure
- Invalid queue operation
- Unauthorized access attempt
- Patient record duplication
- Database connection failure

## 16.2 Error Handling Rules

| Scenario | Expected Behavior |
|---|---|
| WebSocket disconnects | Client reconnects automatically and fetches latest queue state |
| Duplicate token attempted | System blocks request and shows clear message |
| Doctor is offline | System prevents automatic queue assignment to that doctor |
| Appointment conflict | System prevents booking and shows conflict reason |
| Redis unavailable | System continues core database operations and uses fallback polling if needed |
| SMS fails | System logs failure and does not block token creation |
| Invalid queue action | System rejects request with validation error |
| Unauthorized request | System returns access denied response |

## 16.3 User-Friendly Error Message Requirement

All operational error messages should be clear and actionable.

Examples:

- “This patient already has an active token.”
- “Doctor is currently offline. Please select another doctor or change availability.”
- “This appointment slot is already booked.”
- “Realtime connection lost. Reconnecting automatically.”

---

# 17. Deployment Requirements

## 17.1 Deployment Environment

The system shall support deployment on an Ubuntu VPS using Docker.

## 17.2 Deployment Requirements

| ID | Requirement |
|---|---|
| DEP-001 | The application shall be dockerized. |
| DEP-002 | The system shall support environment-based configuration. |
| DEP-003 | PostgreSQL shall be used as the primary database. |
| DEP-004 | Redis shall be used for realtime Pub/Sub and queue support. |
| DEP-005 | The system shall support automated database backup. |
| DEP-006 | The system shall support HTTPS configuration in production. |
| DEP-007 | Logs shall be stored and accessible for troubleshooting. |

## 17.3 Environment Variables

Recommended configuration values include:

```text
APP_ENV
APP_PORT
DATABASE_URL
REDIS_URL
JWT_SECRET
JWT_REFRESH_SECRET
SMS_PROVIDER_API_KEY
SMS_SENDER_ID
FRONTEND_URL
CORS_ALLOWED_ORIGINS
```

---

# 18. Development Phases

## 18.1 Phase 1 — MVP

Phase 1 will focus on the core queue operation.

### Included Features

- Authentication and RBAC
- Hospital profile setup
- Department management
- Doctor management
- Patient search and registration
- Queue token generation
- Doctor queue dashboard
- Reception dashboard
- Realtime queue updates
- Queue display screen
- Basic audit logs

## 18.2 Phase 2 — Operational Expansion

Phase 2 will improve appointment, notification, and reporting capabilities.

### Included Features

- Appointment management
- Appointment-to-queue conversion
- SMS notifications
- Queue near alerts
- Analytics dashboard
- Daily and monthly reports
- Improved audit log views

## 18.3 Phase 3 — Scalability and Advanced Features

Phase 3 will prepare the system for larger deployments.

### Included Features

- Multi-hospital or multi-branch support
- Mobile API support
- QR token system
- WhatsApp notifications
- AI waiting-time prediction
- Voice announcements
- Advanced reporting

---

# 19. Future Enhancements

The following features are outside the initial MVP but may be added later:

- Patient mobile application
- Doctor mobile application
- QR-based self check-in
- WhatsApp notification integration
- AI-based estimated waiting time
- Voice announcement in waiting room
- Multi-branch hospital support
- SaaS-based multi-tenant architecture
- Payment or billing integration
- Patient feedback system
- Digital prescription integration

---

# 20. Success Criteria

The system will be considered successful if the following criteria are met:

| Criteria | Target |
|---|---|
| Queue handling is digital | Yes |
| Queue display updates realtime | Less than 1 second delay |
| Token generation is fast | Less than 2 seconds |
| Reception workflow is smooth | Core actions available on one screen |
| Token operations are low-click | Under 2 clicks for key actions |
| Staff can operate system easily | Minimal training required |
| Patient confusion decreases | Clear token and queue visibility |
| Doctor workflow improves | Clear next-patient control |
| Queue history is auditable | All key state changes logged |

---

# 21. Conclusion

The Digital Hospital Queue Management System is designed to provide a practical, realtime, and scalable solution for hospitals and clinics in Bangladesh.

The system focuses on operational smoothness, speed, and simplicity. The core value of the system is the realtime queue engine, which connects reception, doctors, administrators, and waiting-room displays into one synchronized workflow.

The MVP should prioritize patient registration, token generation, doctor queue control, realtime dashboard updates, and queue display functionality. Appointment management, SMS notifications, reporting, and future mobile or multi-branch capabilities can be expanded in later phases.

By implementing this system, hospitals can reduce manual coordination, improve patient flow, minimize waiting-room confusion, and create a stronger foundation for future digital healthcare operations.

