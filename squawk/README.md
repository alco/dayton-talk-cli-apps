Squawk
======

This is a demo project for a presentation at Dayton Elixir Meetup.

## Prerequisites

You need to set up remote nodes to be able to connect with them. In the demo, I
did that using docker. See the provided Dockerfile for reference.

You may edit the cookie file to make sure it is unique for your setup.

You may also need to update the `:host` env variable in `mix.exs` to match your
local node's IP.

To build the docker image, I first build the Mix project on the host, then run

    docker build -t demoimg .

Launching with docker looks like this (same on each node):

    docker run --rm -it --net=host demoimg bash

Then, to start the node, run

    iex --name <name>@<ip> -S mix


## Running

Build the escript with

    mix escript.build

Add all your nodes to the nodes.txt file and then run

    ./squawk

or

    ./squawk help run

to see which options are supported.


Some example invocations:

    squawk run --all-nodes 'echo hello'

    squawk run -i --split=line --nodes=foo,bar 'grep green' <split_input.txt

    squawk chain 'foo:grep green' 'bar:grep roses' <filter_input.txt
