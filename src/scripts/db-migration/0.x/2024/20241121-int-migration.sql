-- �����µ� User2 ��
CREATE TABLE [dbo].[User2](
    [Id] INT IDENTITY(1,1) NOT NULL,
    [OldId] UNIQUEIDENTIFIER NOT NULL,
    [Avatar] NVARCHAR(1000) NULL,
    [Account] NVARCHAR(1000) NOT NULL,
    [Username] NVARCHAR(1000) NOT NULL,
    [Password] NVARCHAR(1000) NULL,
    [Email] NVARCHAR(1000) NULL,
    [Phone] NVARCHAR(1000) NULL,
    [Role] NVARCHAR(1000) NOT NULL CONSTRAINT [Users2_role_df] DEFAULT('-'),
    [Enabled] BIT NOT NULL CONSTRAINT [Users2_enabled_df] DEFAULT((1)),
    [Provider] NVARCHAR(1000) NULL,
    [Sub] NVARCHAR(1000) NULL,
    [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [Users2_createdAt_df] DEFAULT(GETDATE()),
    [UpdatedAt] DATETIME2(7) NOT NULL,
    CONSTRAINT [Users2_pkey] PRIMARY KEY CLUSTERED ([Id] ASC)
) ON [PRIMARY];

-- �����ݴӾɵ� User ���Ƶ��µ� User2 ��
INSERT INTO [dbo].[User2] (
    [OldId], [Avatar], [Account], [Username], [Password], [Email], [Phone], 
    [Role], [Enabled], [Provider], [Sub], [CreatedAt], [UpdatedAt]
)
SELECT
    [Id] AS OldId, [Avatar], [Account], [Username], [Password], [Email], [Phone], 
    [Role], [Enabled], [Provider], [Sub], [CreatedAt], [UpdatedAt]
FROM [dbo].[User];



-- ======================== ��BalanceTransaction ========================
-- 1. ����µĿɿ��� UserId2 �� CreditUserId2
ALTER TABLE [dbo].[BalanceTransaction]
ADD [UserId2] INT NULL,
    [CreditUserId2] INT NULL;

-- 2. ���ɵ� UserId �� CreditUserId ��Ӧ�µ� User2.Id
UPDATE bt
SET bt.UserId2 = u2.Id
FROM [dbo].[BalanceTransaction] bt
JOIN [dbo].[User2] u2 ON bt.UserId = u2.OldId;

UPDATE bt
SET bt.CreditUserId2 = u2.Id
FROM [dbo].[BalanceTransaction] bt
JOIN [dbo].[User2] u2 ON bt.CreditUserId = u2.OldId;

-- 3. ɾ�����Լ��
ALTER TABLE [dbo].[BalanceTransaction] DROP CONSTRAINT [FK_BalanceLog2_Users];
ALTER TABLE [dbo].[BalanceTransaction] DROP CONSTRAINT [FK_BalanceLog2_CreditUser];

-- 4. ɾ��������������ڣ�
IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_BalanceLog2_User')
    DROP INDEX [IX_BalanceLog2_User] ON [dbo].[BalanceTransaction];

IF EXISTS (SELECT name FROM sys.indexes WHERE name = 'IX_BalanceLog2_CreditUser')
    DROP INDEX [IX_BalanceLog2_CreditUser] ON [dbo].[BalanceTransaction];

-- 5. ɾ���ɵ� UserId �� CreditUserId ��
ALTER TABLE [dbo].[BalanceTransaction]
DROP COLUMN [UserId],
             [CreditUserId];

-- 6. ����������Ϊ UserId �� CreditUserId
EXEC sp_rename '[dbo].[BalanceTransaction].[UserId2]', 'UserId', 'COLUMN';
EXEC sp_rename '[dbo].[BalanceTransaction].[CreditUserId2]', 'CreditUserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[BalanceTransaction]
ALTER COLUMN [UserId] INT NOT NULL;

ALTER TABLE [dbo].[BalanceTransaction]
ALTER COLUMN [CreditUserId] INT NOT NULL;

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[BalanceTransaction]
ADD CONSTRAINT [FK_BalanceTransaction_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User2]([Id]);

ALTER TABLE [dbo].[BalanceTransaction]
ADD CONSTRAINT [FK_BalanceTransaction_CreditUserId] FOREIGN KEY ([CreditUserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE INDEX [IX_BalanceTransaction_UserId] ON [dbo].[BalanceTransaction] ([UserId]);
CREATE INDEX [IX_BalanceTransaction_CreditUserId] ON [dbo].[BalanceTransaction] ([CreditUserId]);

-- ======================== ��Chat ========================
-- 1. ����µĿɿ��� UserId2
ALTER TABLE [dbo].[Chat]
ADD [UserId2] INT NULL;

-- 2. ���ɵ� UserId ��Ӧ�µ� User2.Id
UPDATE c
SET c.UserId2 = u2.Id
FROM [dbo].[Chat] c
JOIN [dbo].[User2] u2 ON c.UserId = u2.OldId;

-- 3. ɾ�����Լ��
ALTER TABLE [dbo].[Chat] DROP CONSTRAINT [FK_Conversation2_Users];

-- 4. ɾ��������������ڣ�
DROP INDEX IX_Conversation2_User ON [dbo].[Chat];

-- 5. ɾ���ɵ� UserId ��
ALTER TABLE [dbo].[Chat] DROP COLUMN [UserId];

-- 6. ����������Ϊ UserId
EXEC sp_rename '[dbo].[Chat].[UserId2]', 'UserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[Chat] ALTER COLUMN [UserId] INT NOT NULL;

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[Chat]
ADD CONSTRAINT [FK_Chat_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE INDEX [IX_Chat_UserId] ON [dbo].[Chat] ([UserId]);

-- ======================== ��InvitationCode ========================
-- 1. ����µĿɿ��� CreateUserId2
ALTER TABLE [dbo].[InvitationCode]
ADD [CreateUserId2] INT NULL;

-- 2. ���ɵ� CreateUserId ��Ӧ�µ� User2.Id
UPDATE ic
SET ic.CreateUserId2 = u2.Id
FROM [dbo].[InvitationCode] ic
JOIN [dbo].[User2] u2 ON ic.CreateUserId = u2.OldId;

-- 5. ɾ���ɵ� CreateUserId ��
ALTER TABLE [dbo].[InvitationCode] DROP COLUMN [CreateUserId];

-- 6. ����������Ϊ CreateUserId
EXEC sp_rename '[dbo].[InvitationCode].[CreateUserId2]', 'CreateUserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[InvitationCode] ALTER COLUMN [CreateUserId] INT NOT NULL;

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[InvitationCode]
ADD CONSTRAINT [FK_InvitationCode_CreateUserId] FOREIGN KEY ([CreateUserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE INDEX [IX_InvitationCode_CreateUserId] ON [dbo].[InvitationCode] ([CreateUserId]);

-- ======================== ��Prompt ========================
-- 1. ����µĿɿ��� CreateUserId2
ALTER TABLE [dbo].[Prompt]
ADD [CreateUserId2] INT NULL;

-- 2. ���ɵ� CreateUserId ��Ӧ�µ� User2.Id
UPDATE p
SET p.CreateUserId2 = u2.Id
FROM [dbo].[Prompt] p
JOIN [dbo].[User2] u2 ON p.CreateUserId = u2.OldId;

-- 3. ɾ�����Լ��
ALTER TABLE [dbo].[Prompt] DROP CONSTRAINT [FK_Prompt2_User];

-- 4. ɾ��������������ڣ�
DROP INDEX IX_Prompt2_CreateUserId ON [dbo].[Prompt];

-- 5. ɾ���ɵ� CreateUserId ��
ALTER TABLE [dbo].[Prompt] DROP COLUMN [CreateUserId];

-- 6. ����������Ϊ CreateUserId
EXEC sp_rename '[dbo].[Prompt].[CreateUserId2]', 'CreateUserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[Prompt] ALTER COLUMN [CreateUserId] INT NOT NULL;

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[Prompt]
ADD CONSTRAINT [FK_Prompt_CreateUserId] FOREIGN KEY ([CreateUserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE INDEX [IX_Prompt_CreateUserId] ON [dbo].[Prompt] ([CreateUserId]);

-- ======================== ��Session ========================
-- 1. ����µĿɿ��� UserId2
ALTER TABLE [dbo].[Session]
ADD [UserId2] INT NULL;

-- 2. ���ɵ� UserId ��Ӧ�µ� User2.Id
UPDATE s
SET s.UserId2 = u2.Id
FROM [dbo].[Session] s
JOIN [dbo].[User2] u2 ON s.UserId = u2.OldId;

-- 3. ɾ�����Լ��
ALTER TABLE [dbo].[Session] DROP CONSTRAINT [FK_Sessions_userId];

-- 4. ɾ��������������ڣ�
-- ����������Ϊ IX_Session_UserId
DROP INDEX ID_Sessions_userId ON [dbo].[Session];

-- 5. ɾ���ɵ� UserId ��
ALTER TABLE [dbo].[Session] DROP COLUMN [UserId];

-- 6. ����������Ϊ UserId
EXEC sp_rename '[dbo].[Session].[UserId2]', 'UserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[Session] ALTER COLUMN [UserId] INT NOT NULL;

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[Session]
ADD CONSTRAINT [FK_Session_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE INDEX [IX_Session_UserId] ON [dbo].[Session] ([UserId]);

-- ======================== ��SmsRecord ========================
-- 1. ����µĿɿ��� UserId2
ALTER TABLE [dbo].[SmsRecord]
ADD [UserId2] INT NULL;

-- 2. ���ɵ� UserId ��Ӧ�µ� User2.Id
UPDATE sr
SET sr.UserId2 = u2.Id
FROM [dbo].[SmsRecord] sr
JOIN [dbo].[User2] u2 ON sr.UserId = u2.OldId;

-- 4. ɾ��������������ڣ�
DROP INDEX IX_SmsHistory_UserId ON [dbo].[SmsRecord];

-- 5. ɾ���ɵ� UserId ��
ALTER TABLE [dbo].[SmsRecord] DROP COLUMN [UserId];

-- 6. ����������Ϊ UserId
EXEC sp_rename '[dbo].[SmsRecord].[UserId2]', 'UserId', 'COLUMN';

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[SmsRecord]
ADD CONSTRAINT [FK_SmsRecord_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE INDEX [IX_SmsRecord_UserId] ON [dbo].[SmsRecord] ([UserId]);


-- ======================== ��UserApiKey ========================
-- 1. ����µĿɿ��� UserId2
ALTER TABLE [dbo].[UserApiKey]
ADD [UserId2] INT NULL;

-- 2. ���ɵ� UserId ��Ӧ�µ� User2.Id
UPDATE uak
SET uak.UserId2 = u2.Id
FROM [dbo].[UserApiKey] uak
JOIN [dbo].[User2] u2 ON uak.UserId = u2.OldId;

-- 3. ɾ�����Լ��
ALTER TABLE [dbo].[UserApiKey] DROP CONSTRAINT [FK_UserApiKey_Users];

-- 4. ɾ��������������ڣ�
DROP INDEX IX_UserApiKey_User ON [dbo].[UserApiKey];

-- 5. ɾ���ɵ� UserId ��
ALTER TABLE [dbo].[UserApiKey] DROP COLUMN [UserId];

-- 6. ����������Ϊ UserId
EXEC sp_rename '[dbo].[UserApiKey].[UserId2]', 'UserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[UserApiKey] ALTER COLUMN [UserId] INT NOT NULL;

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[UserApiKey]
ADD CONSTRAINT [FK_UserApiKey_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE INDEX [IX_UserApiKey_UserId] ON [dbo].[UserApiKey] ([UserId]);

-- ======================== ��UserBalance ========================
-- 1. ����µĿɿ��� UserId2
ALTER TABLE [dbo].[UserBalance]
ADD [UserId2] INT NULL;

-- 2. ���ɵ� UserId ��Ӧ�µ� User2.Id
UPDATE ub
SET ub.UserId2 = u2.Id
FROM [dbo].[UserBalance] ub
JOIN [dbo].[User2] u2 ON ub.UserId = u2.OldId;

-- 3. ɾ�����Լ��
ALTER TABLE [dbo].[UserBalance] DROP CONSTRAINT UserBalances_userId_key;
ALTER TABLE [dbo].[UserBalance] DROP CONSTRAINT UserBalances_userId_fkey;

-- 4. ɾ��������������ڣ�
DROP INDEX IDX_UserBalances_userId ON [dbo].[UserBalance];

-- 5. ɾ���ɵ� UserId ��
ALTER TABLE [dbo].[UserBalance] DROP COLUMN [UserId];

-- 6. ����������Ϊ UserId
EXEC sp_rename '[dbo].[UserBalance].[UserId2]', 'UserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[UserBalance] ALTER COLUMN [UserId] INT NOT NULL;

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[UserBalance]
ADD CONSTRAINT [FK_UserBalance_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE UNIQUE INDEX [UserBalances_userId_key] ON [dbo].[UserBalance] ([UserId]);


-- ======================== ��UserModel ========================
-- 1. ����µĿɿ��� UserId2
ALTER TABLE [dbo].[UserModel]
ADD [UserId2] INT NULL;

-- 2. ���ɵ� UserId ��Ӧ�µ� User2.Id
UPDATE um
SET um.UserId2 = u2.Id
FROM [dbo].[UserModel] um
JOIN [dbo].[User2] u2 ON um.UserId = u2.OldId;

-- 3. ɾ�����Լ��
ALTER TABLE [dbo].[UserModel] DROP CONSTRAINT [FK_UserModel2_User];

-- 4. ɾ��������������ڣ�
DROP INDEX IX_UserModel2_UserId ON [dbo].[UserModel];

-- 5. ɾ���ɵ� UserId ��
ALTER TABLE [dbo].[UserModel] DROP COLUMN [UserId];

-- 6. ����������Ϊ UserId
EXEC sp_rename '[dbo].[UserModel].[UserId2]', 'UserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[UserModel] ALTER COLUMN [UserId] INT NOT NULL;

-- 8. ����µ����Լ��
ALTER TABLE [dbo].[UserModel]
ADD CONSTRAINT [FK_UserModel_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User2]([Id]);

-- 9. ���´��������������Ҫ��
CREATE INDEX [IX_UserModel_UserId] ON [dbo].[UserModel] ([UserId]);

-- ======================== ��UserInvitation�����⴦�� ========================
-- 1. ����µĿɿ��� UserId2
ALTER TABLE [dbo].[UserInvitation]
ADD [UserId2] INT NULL;

-- 2. ���ɵ� UserId ��Ӧ�µ� User2.Id
UPDATE ui
SET ui.UserId2 = u2.Id
FROM [dbo].[UserInvitation] ui
JOIN [dbo].[User2] u2 ON ui.UserId = u2.OldId;

-- 3. ɾ�����������Լ��
ALTER TABLE [dbo].[UserInvitation] DROP CONSTRAINT [FK_UserInvitation_Users];
ALTER TABLE [dbo].[UserInvitation] DROP CONSTRAINT [PK_UserInvitation_1];

-- 4. ɾ��������������ڣ�
DROP INDEX IX_UserInvitation_User ON [dbo].[UserInvitation]

-- 5. ɾ���ɵ� UserId ��
ALTER TABLE [dbo].[UserInvitation] DROP COLUMN [UserId];

-- 6. ����������Ϊ UserId
EXEC sp_rename '[dbo].[UserInvitation].[UserId2]', 'UserId', 'COLUMN';

-- 7. ��������Ϊ NOT NULL
ALTER TABLE [dbo].[UserInvitation] ALTER COLUMN [UserId] INT NOT NULL;

-- 8. ���´�������Լ��
ALTER TABLE [dbo].[UserInvitation]
ADD CONSTRAINT [PK_UserInvitation_1] PRIMARY KEY CLUSTERED ([UserId], [InvitationCodeId]);

-- 9. ����µ����Լ��
ALTER TABLE [dbo].[UserInvitation]
ADD CONSTRAINT [FK_UserInvitation_Users] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User2]([Id]);

-- ���������ָ� User ��

-- 1. ɾ���ɵ� User ��
DROP TABLE [dbo].[User];

-- 2. �� User2 ��������Ϊ User ��
EXEC sp_rename '[dbo].[User2]', 'User';

-- 3. ɾ���µ� User ���е� OldId ��
ALTER TABLE [dbo].[User] DROP COLUMN [OldId];












-- ========================================
-- Step 1: �޸� InvitationCode ��
-- ========================================

-- 1.1 �����µ� InvitationCode2 ��
CREATE TABLE [dbo].[InvitationCode2](
    [Id] INT IDENTITY(1,1) NOT NULL,  -- �µ���������
    [OldId] UNIQUEIDENTIFIER NOT NULL, -- ����ɵ�Ψһ��ʶ��
    [Value] NVARCHAR(100) NOT NULL,
    [Count] SMALLINT NOT NULL,
    [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_InvitationCode_CreatedAt] DEFAULT (GETDATE()),
    [IsDeleted] BIT NOT NULL CONSTRAINT [DF_InvitationCode_isDeleted] DEFAULT ((0)),
    [CreateUserId] INT NOT NULL,
    CONSTRAINT [InvitationCode2_pkey] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [InvitationCode2_value_key] UNIQUE NONCLUSTERED ([Value] ASC)
);

-- 1.2 �����ݴӾɵ� InvitationCode ���Ƶ��µ� InvitationCode2 ��
INSERT INTO [dbo].[InvitationCode2] (
    [OldId], [Value], [Count], [CreatedAt], [IsDeleted], [CreateUserId]
)
SELECT
    [Id] AS OldId, [Value], [Count], [CreatedAt], [IsDeleted], [CreateUserId]
FROM [dbo].[InvitationCode];

-- 1.3 �������� InvitationCode ��������ϵ

-- ��UserInvitation
ALTER TABLE [dbo].[UserInvitation]
ADD [InvitationCodeId2] INT NULL;

UPDATE ui
SET ui.InvitationCodeId2 = ic2.Id
FROM [dbo].[UserInvitation] ui
JOIN [dbo].[InvitationCode2] ic2 ON ui.InvitationCodeId = ic2.OldId;

ALTER TABLE [dbo].[UserInvitation] DROP CONSTRAINT [FK_UserInvitation_InvitationCode];
ALTER TABLE [dbo].[UserInvitation] DROP CONSTRAINT [PK_UserInvitation_1];
ALTER TABLE [dbo].[UserInvitation] DROP COLUMN [InvitationCodeId];

EXEC sp_rename '[dbo].[UserInvitation].[InvitationCodeId2]', 'InvitationCodeId', 'COLUMN';

ALTER TABLE [dbo].[UserInvitation] ALTER COLUMN [InvitationCodeId] INT NOT NULL;

ALTER TABLE [dbo].[UserInvitation]
ADD CONSTRAINT [PK_UserInvitation_1] PRIMARY KEY CLUSTERED ([UserId], [InvitationCodeId]);

ALTER TABLE [dbo].[UserInvitation]
ADD CONSTRAINT [FK_UserInvitation_InvitationCode] FOREIGN KEY ([InvitationCodeId]) REFERENCES [dbo].[InvitationCode2]([Id]);

-- ��UserInitialConfig
ALTER TABLE [dbo].[UserInitialConfig]
ADD [InvitationCodeId2] INT NULL;

UPDATE uic
SET uic.InvitationCodeId2 = ic2.Id
FROM [dbo].[UserInitialConfig] uic
JOIN [dbo].[InvitationCode2] ic2 ON uic.InvitationCodeId = ic2.OldId;

ALTER TABLE [dbo].[UserInitialConfig] DROP CONSTRAINT [FK_UserInitialConfig_InvitationCode];
DROP INDEX [IX_UserInitialConfig_InvitationCodeId] ON [dbo].[UserInitialConfig];

ALTER TABLE [dbo].[UserInitialConfig] DROP COLUMN [InvitationCodeId];

EXEC sp_rename '[dbo].[UserInitialConfig].[InvitationCodeId2]', 'InvitationCodeId', 'COLUMN';

-- InvitationCodeId ��ԭ�����ǿɿյģ����Բ���Ҫ����Ϊ NOT NULL

ALTER TABLE [dbo].[UserInitialConfig]
ADD CONSTRAINT [FK_UserInitialConfig_InvitationCode] FOREIGN KEY ([InvitationCodeId]) REFERENCES [dbo].[InvitationCode2]([Id]);

CREATE INDEX [IX_UserInitialConfig_InvitationCodeId] ON [dbo].[UserInitialConfig] ([InvitationCodeId]);

-- 1.4 ɾ���ɵ� InvitationCode ���������±���ɾ�� OldId ��
DROP TABLE [dbo].[InvitationCode];
EXEC sp_rename '[dbo].[InvitationCode2]', 'InvitationCode';
ALTER TABLE [dbo].[InvitationCode] DROP COLUMN [OldId];









-- ========================================
-- Step 2: �޸� UserInitialConfig ��
-- ========================================

-- 2.1 �����µ� UserInitialConfig2 ��
CREATE TABLE [dbo].[UserInitialConfig2](
    [Id] INT IDENTITY(1,1) NOT NULL,  -- �µ���������
    [OldId] UNIQUEIDENTIFIER NOT NULL, -- ����ɵ�Ψһ��ʶ��
    [Name] NVARCHAR(50) NOT NULL,
    [LoginType] NVARCHAR(50) NULL,
    [Price] DECIMAL(32, 16) NOT NULL CONSTRAINT [DF_UserInitialConfig_price] DEFAULT ((0)),
    [Models] NVARCHAR(4000) NOT NULL CONSTRAINT [DF_UserInitialConfig_models] DEFAULT ('[]'),
    [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_UserInitialConfig_createdAt] DEFAULT (GETDATE()),
    [UpdatedAt] DATETIME2(7) NOT NULL,
    [InvitationCodeId] INT NULL,
    CONSTRAINT [PK_UserInitialConfig] PRIMARY KEY CLUSTERED ([Id] ASC)
);

-- 2.2 �����ݴӾɵ� UserInitialConfig ���Ƶ��µ� UserInitialConfig2 ��
INSERT INTO [dbo].[UserInitialConfig2] (
    [OldId], [Name], [LoginType], [Price], [Models], [CreatedAt], [UpdatedAt], [InvitationCodeId]
)
SELECT
    [Id] AS OldId, [Name], [LoginType], [Price], [Models], [CreatedAt], [UpdatedAt], [InvitationCodeId]
FROM [dbo].[UserInitialConfig];

-- 2.3 ɾ���ɵ� UserInitialConfig ���������±���ɾ�� OldId ��
DROP TABLE [dbo].[UserInitialConfig];
EXEC sp_rename '[dbo].[UserInitialConfig2]', 'UserInitialConfig';
ALTER TABLE [dbo].[UserInitialConfig] DROP COLUMN [OldId];

-- 2.4 �ؽ����Լ�������ڲ��� 1.3 �д���





-- ========================================
-- Step 3: �޸� FileService ��
-- ========================================

-- 3.1 �����µ� FileService2 ��
CREATE TABLE [dbo].[FileService2](
    [Id] INT IDENTITY(1,1) NOT NULL, -- �µ���������
    [OldId] UNIQUEIDENTIFIER NOT NULL, -- ����ɵ�Ψһ��ʶ��
    [Name] NVARCHAR(1000) NOT NULL,
    [Enabled] BIT NOT NULL CONSTRAINT [DF_FileServices_enabled] DEFAULT ((1)),
    [Type] NVARCHAR(1000) NOT NULL,
    [Configs] NVARCHAR(2048) NOT NULL CONSTRAINT [DF_FileServices_configs] DEFAULT ('{}'),
    [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_FileServices_createdAt] DEFAULT (GETDATE()),
    [UpdatedAt] DATETIME2(7) NOT NULL,
    CONSTRAINT [PK_FileServices2] PRIMARY KEY CLUSTERED ([Id] ASC)
);

-- 3.2 �����ݴӾɵ� FileService ���Ƶ��µ� FileService2 ��
INSERT INTO [dbo].[FileService2] (
    [OldId], [Name], [Enabled], [Type], [Configs], [CreatedAt], [UpdatedAt]
)
SELECT
    [Id] AS OldId, [Name], [Enabled], [Type], [Configs], [CreatedAt], [UpdatedAt]
FROM [dbo].[FileService];

-- 3.3 �������� FileService ��������ϵ

-- ��Model
ALTER TABLE [dbo].[Model]
ADD [FileServiceId2] INT NULL;

UPDATE m
SET m.FileServiceId2 = fs2.Id
FROM [dbo].[Model] m
JOIN [dbo].[FileService2] fs2 ON m.FileServiceId = fs2.OldId;

ALTER TABLE [dbo].[Model] DROP CONSTRAINT [FK_Model_FileService];
DROP INDEX [IX_Model_FileServiceId] ON [dbo].[Model];

ALTER TABLE [dbo].[Model] DROP COLUMN [FileServiceId];

EXEC sp_rename '[dbo].[Model].[FileServiceId2]', 'FileServiceId', 'COLUMN';

-- ԭ���� FileServiceId �ǿɿյģ����������Ϊ NOT NULL

ALTER TABLE [dbo].[Model]
ADD CONSTRAINT [FK_Model_FileServiceId] FOREIGN KEY ([FileServiceId]) REFERENCES [dbo].[FileService2]([Id]);

CREATE INDEX [IX_Model_FileServiceId] ON [dbo].[Model] ([FileServiceId]);

-- 3.4 ɾ���ɵ� FileService ���������±���ɾ�� OldId ��
DROP TABLE [dbo].[FileService];
EXEC sp_rename '[dbo].[FileService2]', 'FileService';
ALTER TABLE [dbo].[FileService] DROP COLUMN [OldId];




-- ========================================
-- Step 4: �޸� LoginService ��
-- ========================================

-- 4.1 �����µ� LoginService2 ��
CREATE TABLE [dbo].[LoginService2](
    [Id] INT IDENTITY(1,1) NOT NULL, -- �µ���������
    [OldId] UNIQUEIDENTIFIER NOT NULL, -- ����ɵ�Ψһ��ʶ��
    [Type] NVARCHAR(1000) NOT NULL,
    [Enabled] BIT NOT NULL CONSTRAINT [DF_LoginServices_enabled] DEFAULT ((1)),
    [Configs] NVARCHAR(2048) NOT NULL CONSTRAINT [DF_LoginServices_configs] DEFAULT ('{}'),
    [CreatedAt] DATETIME2(7) NOT NULL CONSTRAINT [DF_LoginServices_createdAt] DEFAULT (GETDATE()),
    [UpdatedAt] DATETIME2(7) NOT NULL,
    CONSTRAINT [PK_LoginServices2] PRIMARY KEY CLUSTERED ([Id] ASC)
);

-- 4.2 �����ݴӾɵ� LoginService ���Ƶ��µ� LoginService2 ��
INSERT INTO [dbo].[LoginService2] (
    [OldId], [Type], [Enabled], [Configs], [CreatedAt], [UpdatedAt]
)
SELECT
    [Id] AS OldId, [Type], [Enabled], [Configs], [CreatedAt], [UpdatedAt]
FROM [dbo].[LoginService];

-- 4.3 ɾ���ɵ� LoginService ���������±���ɾ�� OldId ��
DROP TABLE [dbo].[LoginService];
EXEC sp_rename '[dbo].[LoginService2]', 'LoginService';
ALTER TABLE [dbo].[LoginService] DROP COLUMN [OldId];







-- ========================================
-- Step 5: �޸� Session ��
-- ========================================

-- 5.1 �����µ� Session2 ��
CREATE TABLE [dbo].[Session2](
    [Id] INT IDENTITY(1,1) NOT NULL, -- �µ���������
    [OldId] UNIQUEIDENTIFIER NOT NULL, -- ����ɵ�Ψһ��ʶ��
    [CreatedAt] DATETIME2(7) NOT NULL,
    [UpdatedAt] DATETIME2(7) NOT NULL,
    [UserId] INT NOT NULL,
    CONSTRAINT [PK_Sessions2] PRIMARY KEY CLUSTERED ([Id] ASC)
);

-- 5.2 �����ݴӾɵ� Session ���Ƶ��µ� Session2 ��
INSERT INTO [dbo].[Session2] (
    [OldId], [CreatedAt], [UpdatedAt], [UserId]
)
SELECT
    [Id] AS OldId, [CreatedAt], [UpdatedAt], [UserId]
FROM [dbo].[Session];

-- 5.3 ɾ�����Լ��������
ALTER TABLE [dbo].[Session] DROP CONSTRAINT [FK_Session_UserId];
DROP INDEX [IX_Session_UserId] ON [dbo].[Session];

-- 5.4 ɾ���ɵ� Session ���������±���ɾ�� OldId ��
DROP TABLE [dbo].[Session];
EXEC sp_rename '[dbo].[Session2]', 'Session';
ALTER TABLE [dbo].[Session] DROP COLUMN [OldId];

-- 5.5 ���´������Լ��������
ALTER TABLE [dbo].[Session]
ADD CONSTRAINT [FK_Session_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User]([Id]);

CREATE INDEX [IX_Session_UserId] ON [dbo].[Session] ([UserId]);






-- ========================================
-- Step 6: �޸� UserBalance ��
-- ========================================

-- 6.1 �����µ� UserBalance2 ��
CREATE TABLE [dbo].[UserBalance2](
    [Id] INT IDENTITY(1,1) NOT NULL, -- �µ���������
    [OldId] UNIQUEIDENTIFIER NOT NULL, -- ����ɵ�Ψһ��ʶ��
    [Balance] DECIMAL(32, 16) NOT NULL,
    [CreatedAt] DATETIME2(7) NOT NULL,
    [UpdatedAt] DATETIME2(7) NOT NULL,
    [UserId] INT NOT NULL,
    CONSTRAINT [PK_UserBalances2] PRIMARY KEY CLUSTERED ([Id] ASC)
);

-- 6.2 �����ݴӾɵ� UserBalance ���Ƶ��µ� UserBalance2 ��
INSERT INTO [dbo].[UserBalance2] (
    [OldId], [Balance], [CreatedAt], [UpdatedAt], [UserId]
)
SELECT
    [Id] AS OldId, [Balance], [CreatedAt], [UpdatedAt], [UserId]
FROM [dbo].[UserBalance];

-- 6.3 ɾ�����Լ��������
ALTER TABLE [dbo].[UserBalance] DROP CONSTRAINT [FK_UserBalance_UserId];
DROP INDEX [UserBalances_userId_key] ON [dbo].[UserBalance];

-- 6.4 ɾ���ɵ� UserBalance ���������±���ɾ�� OldId ��
DROP TABLE [dbo].[UserBalance];
EXEC sp_rename '[dbo].[UserBalance2]', 'UserBalance';
ALTER TABLE [dbo].[UserBalance] DROP COLUMN [OldId];

-- 6.5 ���´������Լ��������
ALTER TABLE [dbo].[UserBalance]
ADD CONSTRAINT [FK_UserBalance_UserId] FOREIGN KEY ([UserId]) REFERENCES [dbo].[User]([Id]);

CREATE UNIQUE INDEX [UserBalances_userId_key] ON [dbo].[UserBalance] ([UserId]);


DROP TABLE [Session]

ALTER TABLE dbo.UserInitialConfig ADD CONSTRAINT
	FK_UserInitialConfig_InvitationCode FOREIGN KEY
	(
	InvitationCodeId
	) REFERENCES dbo.InvitationCode
	(
	Id
	) ON UPDATE  SET NULL 
	 ON DELETE  SET NULL 