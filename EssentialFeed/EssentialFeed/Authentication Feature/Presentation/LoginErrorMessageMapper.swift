// LoginErrorMessageMapper.swift
// Presentation layer utility for mapping LoginError to user-facing messages

import Foundation

public enum LoginErrorMessageMapper {
    public static func message(for error: LoginError) -> String {
        switch error {
        case .invalidEmailFormat:
            return "Email format is invalid"
        case .invalidPasswordFormat:
            return "Password does not meet the minimum requirements"
        case .invalidCredentials:
            return "Invalid credentials"
        case .network:
            return "Could not connect. Please try again."
        }
    }
}
