import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 1. Simular retraso de red (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    
    // --- CASO 1: LOGIN (/api/login) ---
    if (options.path.endsWith('/login')) {
      if (options.data['email'] == 'admin' && options.data['password'] == '123456') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            "success": true,
            "message": "Login exitoso",
            "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...", 
            "user": {
              "id": 1,
              "name": "Lucciano Vivas",
              "email": "admin@xtreme.com",
              "role": "admin"
            }
          },
        ));
      } else {
        // Si las credenciales están mal
        return handler.reject(DioException(
          requestOptions: options,
          error: "Credenciales incorrectas",
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: options,
            statusCode: 401,
            data: {"success": false, "message": "Usuario o contraseña inválidos"},
          ),
        ));
      }
    }

    // --- CASO 2: SEGUIMIENTOS (/api/seguimientos) ---
    if (options.path.endsWith('/seguimientos')) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: [
            {
          "id": 1,
          "title": "Diagnóstico Inicial Completo",
          "date": "13 Dic. 10:45 am",
          "image":
              "https://i.ytimg.com/vi/0Iw-qWFUOSo/sddefault.jpg?v=68882530",
        },
        {
          "id": 2,
          "title": "Desmontaje de Ruedas",
          "date": "15 Dic. 12:10 am",
          "image": "https://i.ytimg.com/vi/KF_23BmRnVE/maxresdefault.jpg",
        },
        {
          "id": 3,
          "title": "Reparación de Motor",
          "date": "18 Dic. 09:30 am",
          "image":
              "https://aprende.com/wp-content/uploads/2024/02/manos-sosteniendo-parte-de-un-motor.webp",
        },
           {
            "id": 4,
            "title": "Pintura y Pulido Final",
            "date": "20 Dic. 04:00 pm",
            "image": "https://i.ytimg.com/vi/NFmSJIEzNkg/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGDQgTSh_MA8=&rs=AOn4CLCr86u2Qa_iBlG93u9XqriT76flmQg",
          },
        ],
      ));
    }

    handler.next(options);
  }
}