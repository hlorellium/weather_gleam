import wisp.{type Request, type Response}
import weather/web.{type Context}
import weather/web/weather.{get_current_weather}
import gleam/float
import lustre/element.{text}
import lustre/element/html
import lustre/attribute

/// The HTML page for the weather feature.
pub fn weather_page(req: Request, ctx: Context) -> Response {
  let assert Ok(current_weather) = get_current_weather(ctx)

  html.div([], [
    html.head([], [
      html.title([], "Weather"),
      // html.script([], [attrs.src("https://unpkg.com/htmx.org@1.9.11")], ""),
      html.script([], ""),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href("/static/styles.css"),
      ]),
    ]),
    html.div([], [
      html.h1([], [text("Weather")]),
      html.p([], [
        text(
          "The current temperature is "
          <> current_weather.temperature_2m
          |> float.to_string(),
        ),
      ]),
    ]),
  ])
  |> element.to_string_builder()
  |> wisp.html_response(200)
}
