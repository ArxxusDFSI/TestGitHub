public abstract class DRS_GlobalException extends System.Exception {
    public class DataNotFoundException extends DRS_GlobalException {}
    public class ValidationException extends DRS_GlobalException {}
    public class ServiceException extends DRS_GlobalException {}
    public class RestServiceException extends DRS_GlobalException {}
}