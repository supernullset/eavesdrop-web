# EavesdropWeb

Welcome!

The original Eavesdrop was built for the 2012 Node KO in ~48 hours. It
used the Rdio (streaming music service, now defunct) API so that Rdio
users could act as DJ for their friends (through the service). When a
user(A) changed their song on Rdio, eavesdrop would pick up the change
and broadcast it to any of their(As) friends who were listening
through the eavesdrop web app.

I aim to recreate the project with Elixir/OTP. Ultimately, I aim to
make the music service backend agnostic; I will have to see how that
goes.

At this time, there exists a toy implementation using the
[EavesdropOTP](https://github.com/supernullset/eavesdrop-otp) library
which is implemented using `gen_fsm` and `GenEvent`. I am as of yet
unsure how I will end up plugging all this in.
