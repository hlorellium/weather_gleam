import wisp.{type Request, type Response}
import gleam/string_builder
import weather/web.{type Context}
import weather/web/weather as weather_routes
import weather/pages/weather.{weather_page}

/// The HTTP request handler your application!
///
pub fn handle_request(req: Request, ctx: Context) -> Response {
  // Apply the middleware stack for this request/response.
  use req <- web.middleware(req, ctx)

  // A new `weather/web/weather` module now contains the handlers and other functions
  // relating to the People feature of the application.
  //
  // The router module now only deals with routing, and dispatches to the
  // feature modules for handling requests.
  //
  case wisp.path_segments(req) {
    ["weather"] -> weather_page(req, ctx)
    ["api", "weather", "current"] -> weather_routes.current(req, ctx)
    _ -> wisp.not_found()
  }
}
