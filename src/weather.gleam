import gleam/erlang/process
import gleam/io
import mist
import wisp
import weather/router
import weather/web
import sqlight

pub fn main() {
  io.println("Hello from weather!")

  let secret_key_base = wisp.random_string(64)

  use conn <- sqlight.with_connection(":memory:")

  // A context is constructed to hold the database connection.
  let context = web.Context(conn: conn, static_directory: static_directory())

  let handler = router.handle_request(_, context)

  // Start the Mist web server.
  let assert Ok(_) =
    wisp.mist_handler(handler, secret_key_base)
    |> mist.new
    |> mist.port(8000)
    |> mist.start_http

  // The web server runs in new Erlang process, so put this one to sleep while
  // it works concurrently.
  process.sleep_forever()
}

pub fn static_directory() -> String {
  // The priv directory is where we store non-Gleam and non-Erlang files,
  // including static assets to be served.
  // This function returns an absolute path and works both in development and in
  // production after compilation.
  let assert Ok(priv_directory) = wisp.priv_directory("weather")
  priv_directory <> "/static"
}
