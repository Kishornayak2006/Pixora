class PixoraException(Exception):
    """Base exception for Pixora."""


class ResourceNotFoundError(PixoraException):
    def __init__(self, message: str):
        super().__init__(message)


class DuplicatePhotoError(PixoraException):
    def __init__(self, message: str):
        super().__init__(message)


class ValidationError(PixoraException):
    def __init__(self, message: str):
        super().__init__(message)


class UnauthorizedError(PixoraException):
    def __init__(self, message: str):
        super().__init__(message)