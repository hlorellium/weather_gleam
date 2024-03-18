import wisp.{type Request, type Response}
import weather/web.{type Context}
import gleam/http.{Get, Post}
import gleam/json
import gleam/http/request
import gleam/http/response
import gleam/result
import gleam/httpc
import gleam/dynamic.{field, float, int, list, string}
import gleam/dict

pub fn current(req: Request, ctx: Context) -> Response {
  let assert Ok(current_weather) = get_current_weather(ctx)

  case req.method {
    Get -> {
      wisp.json_response(
        json.to_string_builder(
          json.object([
            #(
              "current_weather",
              json.object([
                #("time", json.string(current_weather.time)),
                #("temperature_2m", json.float(current_weather.temperature_2m)),
                #("wind_speed_10m", json.float(current_weather.wind_speed_10m)),
              ]),
            ),
          ]),
        ),
        200,
      )
    }
    _ -> wisp.method_not_allowed([Get])
  }
}

// Define type for the current weather conditions
pub type CurrentWeather {
  CurrentWeather(time: String, temperature_2m: Float, wind_speed_10m: Float)
}

// Define type for the hourly weather data
pub type HourlyWeatherData {
  HourlyWeatherData(
    time: List(String),
    wind_speed_10m: List(Float),
    temperature_2m: List(Float),
    relative_humidity_2m: List(Int),
  )
}

// Define the top-level type that includes both current and hourly data
pub type WeatherReport {
  WeatherReport(current: CurrentWeather, hourly: HourlyWeatherData)
}

pub fn get_current_weather(ctx: Context) -> Result(CurrentWeather, Nil) {
  // Prepare a HTTP request record
  let assert Ok(req) =
    request.to(
      "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=1.41&current=temperature_2m,wind_speed_10m&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m",
    )

  let weather_resp_decoder =
    dynamic.decode2(
      WeatherReport,
      field(
        "current",
        dynamic.decode3(
          CurrentWeather,
          field("time", of: string),
          field("temperature_2m", of: float),
          field("wind_speed_10m", of: float),
        ),
      ),
      field(
        "hourly",
        dynamic.decode4(
          HourlyWeatherData,
          field("time", of: list(string)),
          field("wind_speed_10m", of: list(float)),
          field("temperature_2m", of: list(float)),
          field("relative_humidity_2m", of: list(int)),
        ),
      ),
    )

  let assert Ok(resp) = httpc.send(req)

  json.decode(from: resp.body, using: weather_resp_decoder)
  |> result.nil_error
  |> result.try(fn(weather_report) {
    let current_weather = weather_report.current

    Ok(current_weather)
  })
}
