module Gfx where

import Color
import Graphics.Element exposing (Element)
import Graphics.Collage as C
import Array
import Random
import Time
import Debug

canvas : List C.Form -> Element
canvas = 
  let 
    width = 800
  in
    C.collage width width


-- Draws concentric circles of random shapes
rings : Random.Seed -> Time.Time -> (C.Form, Random.Seed)
rings seed t = 
  let
    (_, s0) = Random.generate (Random.int 101 201) seed
    (ring1, s1) = ring s0 250 t
    (ring2, s2) = ring s1 150 t
  in
    (C.group [ring1, ring2], s2)


-- Draws a circle of identical randomly-chosen shapes $dist from the origin
ring : Random.Seed -> Int -> Time.Time -> (C.Form, Random.Seed)
ring seed dist t = 
  let
    (_, s0) = Random.generate (Random.int 0 0) seed
    (shape, s1) = Random.generate genShape s0
    (dist, s2) = Random.generate (Random.int (dist-50) (dist+50)) s1
    (angle, s3) = Random.generate (Random.int 0 90) s2
    rotation = ((toFloat angle) + (Time.inMilliseconds t)/100)
  in
    (fourfold shape (toFloat dist) rotation, s3)


genColor : Random.Generator Color.Color
genColor = 
  let
    n = (Array.length choices) - 1
    color = \i -> Array.get i choices |> Maybe.withDefault Color.black
    choices = Array.fromList
      [ Color.red
      , Color.green
      , Color.green
      , Color.blue
      , Color.purple
      , Color.orange
      ]
  in
    Random.map color (Random.int 0 n)


genShape : Random.Generator C.Form
genShape = 
  let
    map = \color sides size -> C.filled color (C.ngon sides (toFloat size))
  in
    Random.map3 map genColor (Random.int 3 8) (Random.int 10 80)


-- fourfold duplicates the shape four times.
fourfold : C.Form -> Float -> Float -> C.Form
fourfold shape dist angle = C.group 
  [ C.move (0, dist) shape
  , C.move (0, -dist) shape
  , C.move (dist, 0) shape
  , C.move (-dist, 0) shape
  ] |> C.rotate (degrees angle)
