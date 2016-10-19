import Vapor

let drop = Droplet()

guard let apiKey = drop.config["app", "nasa-api-key"]?.string else {
    fatalError("Please add app.nasa-api-key to config.")
}

drop.get { req in
    let rover = req.data["rover"]?.string ?? "spirit"
    let sol = req.data["sol"]?.int ?? 1
    let camera = req.data["camera"]?.string ?? "PANCAM"

    let apiRes = try drop.client.get("https://api.nasa.gov/mars-photos/api/v1/rovers/\(rover)/photos", query: [
        "sol": sol,
        "camera": camera,
        "api_key": apiKey
    ])

    let images = apiRes.data["photos", "img_src"]?.array?.flatMap({ $0.string }) ?? []

    if req.accept.prefers("html") {
        return try drop.view.make("images", [
            "images": try Node(node: images),
            "rover": rover,
            "sol": sol,
            "camera": camera
        ])
    } else {
        return try JSON(node: images)
    }
}

drop.run()
