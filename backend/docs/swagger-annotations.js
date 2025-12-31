/**
 * @swagger
 * tags:
 *   - name: Authentication
 *     description: User authentication and registration
 *   - name: Loans
 *     description: Loan request management
 *   - name: Repayments
 *     description: Repayment tracking and management
 *   - name: Reports
 *     description: User reporting and moderation
 *   - name: Disputes
 *     description: Dispute management
 *   - name: Notifications
 *     description: User notifications
 *   - name: Admin
 *     description: Admin management endpoints
 */

/**
 * @swagger
 * /auth/register:
 *   post:
 *     summary: Register a new user
 *     tags: [Authentication]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *               - role
 *               - firstName
 *               - lastName
 *               - phone
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *                 minLength: 6
 *               role:
 *                 type: string
 *                 enum: [lender, borrower]
 *               firstName:
 *                 type: string
 *               lastName:
 *                 type: string
 *               phone:
 *                 type: string
 *     responses:
 *       201:
 *         description: User registered successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 message:
 *                   type: string
 *                 data:
 *                   type: object
 *                   properties:
 *                     token:
 *                       type: string
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/Error'
 */

/**
 * @swagger
 * /auth/login:
 *   post:
 *     summary: Login user
 *     tags: [Authentication]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     token:
 *                       type: string
 *                     user:
 *                       $ref: '#/components/schemas/User'
 *       401:
 *         description: Invalid credentials
 */

/**
 * @swagger
 * /auth/profile:
 *   get:
 *     summary: Get user profile
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: User profile
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/User'
 *   put:
 *     summary: Update user profile
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               firstName:
 *                 type: string
 *               lastName:
 *                 type: string
 *               phone:
 *                 type: string
 *               whatsapp:
 *                 type: string
 *               address:
 *                 type: string
 *               city:
 *                 type: string
 *               state:
 *                 type: string
 *               pincode:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profile updated successfully
 */

/**
 * @swagger
 * /loans:
 *   get:
 *     summary: Get all loan requests
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, accepted, rejected, fulfilled, in_progress, completed, defaulted, disputed]
 *       - in: query
 *         name: role
 *         schema:
 *           type: string
 *           enum: [borrower, lender]
 *     responses:
 *       200:
 *         description: List of loan requests
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/LoanRequest'
 *   post:
 *     summary: Create a new loan request
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - amount
 *               - purpose
 *               - duration
 *             properties:
 *               amount:
 *                 type: number
 *                 format: decimal
 *               purpose:
 *                 type: string
 *               duration:
 *                 type: integer
 *                 description: Duration in days
 *               interestRate:
 *                 type: number
 *                 format: decimal
 *     responses:
 *       201:
 *         description: Loan request created successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/LoanRequest'
 */

/**
 * @swagger
 * /loans/{id}:
 *   get:
 *     summary: Get loan request by ID
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Loan request details
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   $ref: '#/components/schemas/LoanRequest'
 *       404:
 *         description: Loan request not found
 *   put:
 *     summary: Update loan request
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               amount:
 *                 type: number
 *               purpose:
 *                 type: string
 *               duration:
 *                 type: integer
 *               interestRate:
 *                 type: number
 *     responses:
 *       200:
 *         description: Loan request updated successfully
 */

/**
 * @swagger
 * /loans/{id}/accept:
 *   post:
 *     summary: Accept a loan request (lender)
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               interestRate:
 *                 type: number
 *     responses:
 *       200:
 *         description: Loan request accepted
 */

/**
 * @swagger
 * /loans/{id}/fulfill:
 *   post:
 *     summary: Mark loan as fulfilled (money received)
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Loan marked as fulfilled
 */

/**
 * @swagger
 * /loans/{id}/repayments:
 *   get:
 *     summary: Get repayments for a loan
 *     tags: [Repayments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: List of repayments
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Repayment'
 *   post:
 *     summary: Record a repayment
 *     tags: [Repayments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - amount
 *               - paymentMethod
 *             properties:
 *               amount:
 *                 type: number
 *               paymentMethod:
 *                 type: string
 *                 enum: [cash, bank_transfer, upi, cheque, other]
 *               transactionReference:
 *                 type: string
 *               remarks:
 *                 type: string
 *     responses:
 *       201:
 *         description: Repayment recorded successfully
 */

/**
 * @swagger
 * /reports:
 *   get:
 *     summary: Get all reports (admin only)
 *     tags: [Reports]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of reports
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Report'
 *   post:
 *     summary: File a report
 *     tags: [Reports]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - reportedUserId
 *               - reportType
 *               - description
 *             properties:
 *               reportedUserId:
 *                 type: string
 *                 format: uuid
 *               loanRequestId:
 *                 type: string
 *                 format: uuid
 *               reportType:
 *                 type: string
 *                 enum: [fraud, harassment, non_payment, false_information, inappropriate_behavior, other]
 *               description:
 *                 type: string
 *     responses:
 *       201:
 *         description: Report filed successfully
 */

/**
 * @swagger
 * /disputes:
 *   get:
 *     summary: Get all disputes
 *     tags: [Disputes]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of disputes
 *   post:
 *     summary: Raise a dispute
 *     tags: [Disputes]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - loanRequestId
 *               - againstUserId
 *               - disputeType
 *               - description
 *             properties:
 *               loanRequestId:
 *                 type: string
 *                 format: uuid
 *               againstUserId:
 *                 type: string
 *                 format: uuid
 *               disputeType:
 *                 type: string
 *                 enum: [payment_not_received, wrong_amount, unauthorized_charge, terms_violation, other]
 *               description:
 *                 type: string
 *               disputedAmount:
 *                 type: number
 *     responses:
 *       201:
 *         description: Dispute raised successfully
 */

/**
 * @swagger
 * /notifications:
 *   get:
 *     summary: Get user notifications
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: unreadOnly
 *         schema:
 *           type: boolean
 *     responses:
 *       200:
 *         description: List of notifications
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/Notification'
 */

/**
 * @swagger
 * /notifications/{id}/read:
 *   put:
 *     summary: Mark notification as read
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Notification marked as read
 */

/**
 * @swagger
 * /admin/users:
 *   get:
 *     summary: Get all users (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: role
 *         schema:
 *           type: string
 *           enum: [lender, borrower]
 *       - in: query
 *         name: verificationStatus
 *         schema:
 *           type: string
 *           enum: [pending, approved, rejected]
 *     responses:
 *       200:
 *         description: List of users
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/User'
 */

/**
 * @swagger
 * /admin/users/{id}/verify:
 *   put:
 *     summary: Verify a user (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               verificationStatus:
 *                 type: string
 *                 enum: [approved, rejected]
 *               rejectionReason:
 *                 type: string
 *     responses:
 *       200:
 *         description: User verification updated
 */

/**
 * @swagger
 * /admin/users/{id}/block:
 *   put:
 *     summary: Block or unblock a user (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               isBlocked:
 *                 type: boolean
 *               blockReason:
 *                 type: string
 *     responses:
 *       200:
 *         description: User block status updated
 */

/**
 * @swagger
 * /admin/dashboard:
 *   get:
 *     summary: Get admin dashboard statistics
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Dashboard statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     totalUsers:
 *                       type: integer
 *                     totalLoans:
 *                       type: integer
 *                     totalAmount:
 *                       type: number
 *                     pendingVerifications:
 *                       type: integer
 *                     activeDisputes:
 *                       type: integer
 */

/**
 * @swagger
 * /auth/onboarding:
 *   post:
 *     summary: Complete user onboarding with documents
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - address
 *               - city
 *               - state
 *               - pincode
 *               - governmentIdType
 *               - governmentIdNumber
 *               - governmentId
 *               - selfiePhoto
 *             properties:
 *               address:
 *                 type: string
 *               city:
 *                 type: string
 *               state:
 *                 type: string
 *               pincode:
 *                 type: string
 *                 pattern: '^\d{6}$'
 *               governmentIdType:
 *                 type: string
 *                 enum: [aadhar, pan, voter_id, passport, driving_license]
 *               governmentIdNumber:
 *                 type: string
 *               lendingLimit:
 *                 type: number
 *                 description: For lenders only
 *               termsAccepted:
 *                 type: boolean
 *               governmentId:
 *                 type: string
 *                 format: binary
 *                 description: Government ID document image
 *               selfiePhoto:
 *                 type: string
 *                 format: binary
 *                 description: Selfie photo for verification
 *               profilePhoto:
 *                 type: string
 *                 format: binary
 *                 description: Optional profile photo
 *     responses:
 *       200:
 *         description: Onboarding completed successfully
 *       400:
 *         description: Validation error
 */

/**
 * @swagger
 * /auth/profile-picture:
 *   post:
 *     summary: Upload profile picture
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - profilePhoto
 *             properties:
 *               profilePhoto:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Profile picture uploaded successfully
 */

/**
 * @swagger
 * /auth/change-password:
 *   post:
 *     summary: Change user password
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - currentPassword
 *               - newPassword
 *             properties:
 *               currentPassword:
 *                 type: string
 *               newPassword:
 *                 type: string
 *                 minLength: 6
 *     responses:
 *       200:
 *         description: Password changed successfully
 *       400:
 *         description: Current password is incorrect
 */

/**
 * @swagger
 * /auth/reset-password:
 *   post:
 *     summary: Reset password (forgot password)
 *     tags: [Authentication]
 *     security: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - newPassword
 *             properties:
 *               email:
 *                 type: string
 *                 format: email
 *               newPassword:
 *                 type: string
 *                 minLength: 8
 *     responses:
 *       200:
 *         description: Password reset successful
 *       404:
 *         description: User not found
 */

/**
 * @swagger
 * /auth/send-email-verification:
 *   post:
 *     summary: Send email verification code
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Verification code sent
 */

/**
 * @swagger
 * /auth/verify-email:
 *   post:
 *     summary: Verify email with code
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - code
 *             properties:
 *               code:
 *                 type: string
 *                 minLength: 6
 *                 maxLength: 6
 *     responses:
 *       200:
 *         description: Email verified successfully
 *       400:
 *         description: Invalid or expired code
 */

/**
 * @swagger
 * /auth/send-phone-verification:
 *   post:
 *     summary: Send phone verification code
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Verification code sent
 */

/**
 * @swagger
 * /auth/verify-phone:
 *   post:
 *     summary: Verify phone with code
 *     tags: [Authentication]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - code
 *             properties:
 *               code:
 *                 type: string
 *                 minLength: 6
 *                 maxLength: 6
 *     responses:
 *       200:
 *         description: Phone verified successfully
 *       400:
 *         description: Invalid or expired code
 */

/**
 * @swagger
 * /loans/request:
 *   post:
 *     summary: Create a new loan request (borrower only)
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - amount
 *               - purpose
 *               - duration
 *             properties:
 *               amount:
 *                 type: number
 *                 minimum: 500
 *                 maximum: 1000000
 *               purpose:
 *                 type: string
 *               duration:
 *                 type: integer
 *                 minimum: 7
 *                 maximum: 365
 *                 description: Duration in days
 *     responses:
 *       201:
 *         description: Loan request created successfully
 *       400:
 *         description: Validation error
 *       403:
 *         description: User not onboarded or verified
 */

/**
 * @swagger
 * /loans/my-requests:
 *   get:
 *     summary: Get my borrow requests (borrower only)
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of borrower's loan requests
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/LoanRequest'
 */

/**
 * @swagger
 * /loans/pending:
 *   get:
 *     summary: Get pending loan requests (lender only)
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of pending loan requests available for lending
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/LoanRequest'
 */

/**
 * @swagger
 * /loans/my-lending:
 *   get:
 *     summary: Get my lending history (lender only)
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of lender's loan history
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/LoanRequest'
 */

/**
 * @swagger
 * /loans/{id}/cancel:
 *   post:
 *     summary: Cancel a loan request (borrower only)
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Loan request cancelled
 *       400:
 *         description: Cannot cancel this loan
 *       404:
 *         description: Loan request not found
 */

/**
 * @swagger
 * /loans/{id}/repayment:
 *   post:
 *     summary: Record a repayment (lender only)
 *     tags: [Repayments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - amount
 *             properties:
 *               amount:
 *                 type: number
 *                 minimum: 1
 *               paymentMethod:
 *                 type: string
 *                 enum: [cash, bank_transfer, upi, cheque, other]
 *               transactionReference:
 *                 type: string
 *               remarks:
 *                 type: string
 *     responses:
 *       201:
 *         description: Repayment recorded successfully
 *       400:
 *         description: Invalid amount or loan status
 */

/**
 * @swagger
 * /loans/{id}/rate:
 *   post:
 *     summary: Rate a user after loan completion
 *     tags: [Loans]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - rating
 *             properties:
 *               rating:
 *                 type: integer
 *                 minimum: 1
 *                 maximum: 5
 *               review:
 *                 type: string
 *     responses:
 *       200:
 *         description: Rating submitted successfully
 *       400:
 *         description: Cannot rate this loan
 */

/**
 * @swagger
 * /disputes/my-disputes:
 *   get:
 *     summary: Get my disputes
 *     tags: [Disputes]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of user's disputes
 */

/**
 * @swagger
 * /disputes/{id}/note:
 *   post:
 *     summary: Add a note to a dispute
 *     tags: [Disputes]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - note
 *             properties:
 *               note:
 *                 type: string
 *               evidence:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Note added successfully
 */

/**
 * @swagger
 * /reports/my-reports:
 *   get:
 *     summary: Get my filed reports
 *     tags: [Reports]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of user's filed reports
 */

/**
 * @swagger
 * /notifications/unread-count:
 *   get:
 *     summary: Get unread notification count
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Unread notification count
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                 data:
 *                   type: object
 *                   properties:
 *                     count:
 *                       type: integer
 */

/**
 * @swagger
 * /notifications/read-all:
 *   put:
 *     summary: Mark all notifications as read
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: All notifications marked as read
 */

/**
 * @swagger
 * /notifications/{id}:
 *   delete:
 *     summary: Delete a notification
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: Notification deleted
 */

/**
 * @swagger
 * /admin/users/{id}:
 *   get:
 *     summary: Get user details (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: User details
 *   delete:
 *     summary: Delete a user (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     responses:
 *       200:
 *         description: User deleted
 */

/**
 * @swagger
 * /admin/users/{id}/reject:
 *   put:
 *     summary: Reject user verification (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - reason
 *             properties:
 *               reason:
 *                 type: string
 *     responses:
 *       200:
 *         description: User verification rejected
 */

/**
 * @swagger
 * /admin/users/{id}/partial-reject:
 *   put:
 *     summary: Partially reject user documents (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - rejections
 *             properties:
 *               rejections:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     type:
 *                       type: string
 *                       enum: [identity, address, selfie]
 *                     reason:
 *                       type: string
 *     responses:
 *       200:
 *         description: Documents partially rejected
 */

/**
 * @swagger
 * /admin/loans:
 *   get:
 *     summary: Get all loans (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of all loans
 */

/**
 * @swagger
 * /admin/settings:
 *   get:
 *     summary: Get platform settings (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Platform settings
 *   put:
 *     summary: Update a platform setting (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - key
 *               - value
 *             properties:
 *               key:
 *                 type: string
 *               value:
 *                 type: string
 *     responses:
 *       200:
 *         description: Setting updated
 */

/**
 * @swagger
 * /admin/settings/initialize:
 *   post:
 *     summary: Initialize default settings (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Settings initialized
 */

/**
 * @swagger
 * /admin/activity-logs:
 *   get:
 *     summary: Get activity logs (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of activity logs
 */

/**
 * @swagger
 * /admin/disputes:
 *   get:
 *     summary: Get all disputes (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of all disputes
 */

/**
 * @swagger
 * /admin/disputes/{id}:
 *   put:
 *     summary: Resolve a dispute (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [open, under_review, resolved, closed]
 *               resolution:
 *                 type: string
 *     responses:
 *       200:
 *         description: Dispute resolved
 */

/**
 * @swagger
 * /admin/reports/{id}:
 *   put:
 *     summary: Update report status (admin only)
 *     tags: [Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *           format: uuid
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - status
 *             properties:
 *               status:
 *                 type: string
 *                 enum: [pending, under_review, resolved, dismissed]
 *               resolution:
 *                 type: string
 *     responses:
 *       200:
 *         description: Report status updated
 */
