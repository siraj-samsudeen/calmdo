defmodule CalmdoWeb.CoreComponentsTest do
  use CalmdoWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias CalmdoWeb.CoreComponents

  describe "<.input>" do
    test "textarea includes phx-update=ignore for preserving height" do
      html =
        render_component(&CoreComponents.input/1,
          name: "Notes",
          value: "foo",
          type: "textarea"
        )

      assert html =~ ~s(phx-update="ignore")
    end
  end
end
