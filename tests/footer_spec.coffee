describe "Footer [000]", ->
  beforeEach ->
    cy
      .visit("/")
      .window().then (win) ->
        {@ipc, @App} = win

        @agents = cy.agents()
        @agents.spy(@App, "ipc")

        @ipc.handle("get:options", null, {})
        @ipc.handle("get:current:user", null, {})

  it "footer displays on app start [02q]", ->
    cy.get("#footer").should("be.visible")

  context "update banner [02r]", ->
    it "does not display update banner when no update available [05k]", ->
      cy.get("#updates-available").should("not.exist")

    it "checks for update on show [05l]", ->
      expect(@App.ipc).to.be.calledWith("updater:check")

    it "displays banner if updater:check if new version [05m]", ->
      @ipc.handle("updater:check", null, "1.3.4")
      cy.get("#updates-available").should("be.visible")
      cy.contains("New updates are available")

    it "triggers open:window on click of Update link [05n]", ->
      @ipc.handle("updater:check", null, "1.3.4")
      cy.contains("Update").click().then ->
        expect(@App.ipc).to.be.calledWith("window:open", {
          position: "center"
          width: 300
          height: 210
          toolbar: false
          title: "Updates"
          type: "UPDATES"
        })