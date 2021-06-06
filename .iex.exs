# project specific stuff
alias Mimicry.Utils
alias Mimicry.{MockServer, MockServerList}

# only relevant outside docker, e.g. when running locally
import_file_if_available("~/.iex.exs")

# additional mountable local .iex.exs
import_file_if_available("./.iex.custom.exs")
