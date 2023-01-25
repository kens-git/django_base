from django.http import HttpRequest, HttpResponse


def index(request: HttpRequest) -> HttpResponse:
    return HttpResponse("<body><h1>Nothing here yet.</h1></body>")
