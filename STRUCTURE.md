## App Structure Overview

The system is orchestrated by the global called the `Conductor`. It manages the state of the site, including all of the navigations, potential pages, routes, and updates `iron-router` routes.

Each page is registered in the Conductor in a module style system. The Conductor adds tiles to the main homepage based on the data in the views, and creates routes for them as well.

**All examples here are in coffeescript but javascript obviously works fine as well.**


### File Structure

Here is the file structure:

- **client** - Everything packaged into the client
- **server** - Everything on the server
- **collections** - Data collections (not used so much in this app)

Each view and all relevant files are stored in its own directory under the client.

- **client/views** - Views container folder
- **client/views/myview/** - View with ID myview


### Creating a View

To register a new part of the site in the Conductor, create a directory in **client/views**. In that directory set up the following files:

**view.coffee** - The core view registration file.

```coffee
    Conductor.registerView
        id: "myview"       # The ID of the view
        slug: "my-view"    # The URL slug of the view
        template: "myView" # The template name of the view
        name: "My View"    # Title of the tile on the home page
        subtitle: "A thing demonstrating My Thing"
        # Supply an icon image
        image: "/images/stuff.png"
        # OR supply a icon template
        iconTemplate: "myAnimatedIcon"
        # Optional subscriptions callback
        subscriptions: ->
            Meteor.subscribe("myData")
        # Optional subscriptions callback to WAIT ON before going to the page.
        waitOn: ->
            Meteor.subscribe("myData")
        # Optional rendered function
        rendered: ->
            console.log "Rendered!"
```

This view registration will let Conductor know about your view. This will create a tile on the home screen of the site and register a URL for your app. 

You can then register your template that you want to render into the body of the page when your route is active. Note that this structure is super flexible, you can name these files whatever you want, and have as many of them as you want to separate templates out.

**view.html**

```html
    <template name="myView">
       {{ > someOtherTemplate }}
       
       Myvariable variable: {{myHelper}}
    </template>
```
    
From here you can fill that template with whatever you want for your view. An example here is including another template named `someOtherTemplate`.

Meteor templating applies here, of course.

**viewtemplate.coffee**

```coffee
    Template.myView.helpers
        "myHelper": ->
            Session.get("myVariable")
    Template.myView.events
        "click .myButton": ->
             alert "Ouch"
```

Conductor will handle animating in and out your page, as well as showing loading screens while the `waitOn` subscriptions take a while to get around to completing.