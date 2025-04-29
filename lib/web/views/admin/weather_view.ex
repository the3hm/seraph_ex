defmodule Web.Admin.WeatherView do
  use Web, :view

  alias Data.Room  # Keep this as it's used in _form.html.eex for ecologies
  alias Web.Router.Helpers, as: Routes
end
