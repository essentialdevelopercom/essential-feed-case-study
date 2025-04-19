| Archivo | Test | Caso de Uso | Checklist Técnico | Presente | Cobertura |
|---------|------|-------------|------------------|----------|-----------|
| UserLoginUseCaseTests.swift | test_login_succeeds_onValidCredentialsAndServerResponse | Autenticación de Usuario | Notificar éxito al observer y almacenar token seguro | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_fails_onInvalidCredentials | Autenticación de Usuario | Manejar error de credenciales y notificar fallo al observer | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely | Registro de Usuario | Crear usuario y almacenar credenciales de forma segura | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar nombre vacío y no llamar a HTTP ni Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar password débil y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_notifiesEmailAlreadyInUsePresenter | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_returnsEmailAlreadyInUseError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withNoConnectivity_returnsConnectivityError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de conectividad y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests+Server.swift | test_registerUser_sendsRequestToServer | Registro de Usuario | Enviar request correctamente al endpoint con datos válidos | Sí | ✅ |

|---------|------|-------------|------------------|----------|-----------|
| UserLoginUseCaseTests.swift | test_login_succeeds_onValidCredentialsAndServerResponse | Autenticación de Usuario | Notificar éxito al observer y almacenar token seguro | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_fails_onInvalidCredentials | Autenticación de Usuario | Manejar error de credenciales y notificar fallo al observer | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely | Registro de Usuario | Crear usuario y almacenar credenciales de forma segura | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar nombre vacío y no llamar a HTTP ni Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar password débil y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_notifiesEmailAlreadyInUsePresenter | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_returnsEmailAlreadyInUseError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withNoConnectivity_returnsConnectivityError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de conectividad y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests+Server.swift | test_registerUser_sendsRequestToServer | Registro de Usuario | Enviar request correctamente al endpoint con datos válidos | Sí | ✅ |

|---------|------|-------------|------------------|----------|-----------|
| UserLoginUseCaseTests.swift | test_login_succeeds_onValidCredentialsAndServerResponse | Autenticación de Usuario | Notificar éxito al observer y almacenar token seguro | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_fails_onInvalidCredentials | Autenticación de Usuario | Manejar error de credenciales y notificar fallo al observer | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely | Registro de Usuario | Crear usuario y almacenar credenciales de forma segura | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar nombre vacío y no llamar a HTTP ni Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar password débil y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_notifiesEmailAlreadyInUsePresenter | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_returnsEmailAlreadyInUseError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withNoConnectivity_returnsConnectivityError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de conectividad y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests+Server.swift | test_registerUser_sendsRequestToServer | Registro de Usuario | Enviar request correctamente al endpoint con datos válidos | Sí | ✅ |

|---------|------|-------------|------------------|----------|-----------|
| UserLoginUseCaseTests.swift | test_login_succeeds_onValidCredentialsAndServerResponse | Autenticación de Usuario | Notificar éxito al observer y almacenar token seguro | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_fails_onInvalidCredentials | Autenticación de Usuario | Manejar error de credenciales y notificar fallo al observer | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely | Registro de Usuario | Crear usuario y almacenar credenciales de forma segura | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar nombre vacío y no llamar a HTTP ni Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar password débil y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_notifiesEmailAlreadyInUsePresenter | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_returnsEmailAlreadyInUseError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withNoConnectivity_returnsConnectivityError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de conectividad y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests+Server.swift | test_registerUser_sendsRequestToServer | Registro de Usuario | Enviar request correctamente al endpoint con datos válidos | Sí | ✅ |

|---------|------|-------------|------------------|----------|-----------|
| UserLoginUseCaseTests.swift | test_login_succeeds_onValidCredentialsAndServerResponse | Autenticación de Usuario | Notificar éxito al observer y almacenar token seguro | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_fails_onInvalidCredentials | Autenticación de Usuario | Manejar error de credenciales y notificar fallo al observer | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely | Registro de Usuario | Crear usuario y almacenar credenciales de forma segura | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar nombre vacío y no llamar a HTTP ni Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar password débil y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_notifiesEmailAlreadyInUsePresenter | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_returnsEmailAlreadyInUseError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withNoConnectivity_returnsConnectivityError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de conectividad y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests+Server.swift | test_registerUser_sendsRequestToServer | Registro de Usuario | Enviar request correctamente al endpoint con datos válidos | Sí | ✅ |

|---------|------|-------------|------------------|----------|-----------|
| UserLoginUseCaseTests.swift | test_login_succeeds_onValidCredentialsAndServerResponse | Autenticación de Usuario | Notificar éxito al observer y almacenar token seguro | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_fails_onInvalidCredentials | Autenticación de Usuario | Manejar error de credenciales y notificar fallo al observer | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely | Registro de Usuario | Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain | Registro de Usuario | Validar password débil y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_notifiesEmailAlreadyInUsePresenter | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_returnsEmailAlreadyInUseError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withNoConnectivity_returnsConnectivityError_andDoesNotStoreCredentials | Registro de Usuario | Manejar error de conectividad y no guardar credenciales | Sí | ✅ |

|---------|------|-------------|------------------|----------|-----------|
| LoadResourcePresenterTests.swift | test_init_doesNotSendMessagesToView | - | - | Sí | ✅ |
| LoadResourcePresenterTests.swift | test_didStartLoading_displaysNoErrorMessageAndStartsLoading | - | - | Sí | ✅ |
| LoadResourcePresenterTests.swift | test_didFinishLoadingResource_displaysResourceAndStopsLoading | - | - | Sí | ✅ |
| LoadResourcePresenterTests.swift | test_didFinishLoadingWithMapperError_displaysLocalizedErrorMessageAndStopsLoading | - | - | Sí | ✅ |
| LoadResourcePresenterTests.swift | test_didFinishLoadingWithError_displaysLocalizedErrorMessageAndStopsLoading | - | - | Sí | ✅ |
| SharedLocalizationTests.swift | test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations | : Internacionalización | : Todas las claves y valores existen para todos los idiomas soportados | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withValidData_createsUserAndStoresCredentialsSecurely | - | - | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withEmptyName_returnsValidationError_andDoesNotCallHTTPOrKeychain | - | - | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withInvalidEmail_returnsValidationError_andDoesNotCallHTTPOrKeychain | : Registro de Usuario | : Validar email y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withWeakPassword_returnsValidationError_andDoesNotCallHTTPOrKeychain | : Registro de Usuario | : Validar password débil y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_notifiesEmailAlreadyInUsePresenter | : Registro de Usuario | : Validar password débil y no llamar a Keychain si es inválido | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withAlreadyRegisteredEmail_returnsEmailAlreadyInUseError_andDoesNotStoreCredentials | : Registro de Usuario | : Manejar error de email ya registrado y no guardar credenciales | Sí | ✅ |
| UserRegistrationUseCaseTests.swift | test_registerUser_withNoConnectivity_returnsConnectivityError_andDoesNotStoreCredentials | : Registro de Usuario | : Manejar error de conectividad y no guardar credenciales | Sí | ✅ |
| KeychainSecureStorageTests.swift | test_saveData_succeeds_whenKeychainSavesSuccessfully | - | - | Sí | ✅ |
| KeychainSecureStorageTests.swift | test_saveData_fails_whenKeychainReturnsError | - | - | Sí | ✅ |
| KeychainSecureStorageTests.swift | test_saveData_usesFallback_whenKeychainFails | - | - | Sí | ✅ |
| KeychainSecureStorageTests.swift | test_saveData_usesAlternativeStorage_whenKeychainAndFallbackFail | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_init_doesNotMessageStoreUponCreation | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_protectionLevel_returnsHighForUnreadableData | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_protectionLevel_returnsHighForSensitiveData | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_protectionLevel_returnsMediumForPersonalData | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_protectionLevel_returnsMediumForCapitalizedNames | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_protectionLevel_returnsLowForPublicData | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_save_encryptsAndStoresHighProtectionData | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_save_encryptsAndStoresMediumProtectionData | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_save_storesLowProtectionDataWithoutEncryption | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_save_failsOnEncryptionError | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_save_throwsErrorWhenEncryptionServiceThrowsUnexpectedError | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_save_throwsErrorWhenStoreThrowsUnexpectedError | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_save_withEmptyData_savesWithLowProtection | - | - | Sí | ✅ |
| SecureStorageTests.swift | test_save_failsOnStoreError | - | - | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_succeeds_onValidCredentialsAndServerResponse | : Autenticación de Usuario | : Notificar éxito al observer y almacenar token seguro | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_fails_onInvalidCredentials | : Autenticación de Usuario | : Manejar error de credenciales y notificar fallo al observer | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_succeeds_onValidCredentialsAndServerResponse | - | - | Sí | ✅ |
| UserLoginUseCaseTests.swift | test_login_fails_onInvalidCredentials | - | - | Sí | ✅ |
