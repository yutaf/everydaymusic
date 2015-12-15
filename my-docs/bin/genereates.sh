#!/usr/bin/env bash

rails g migration CreateJoinTableArtistUser artist user
rails g scaffold user email:string locale:string timezone:integer delivery_time:time is_active:boolean
rails g model facebook user:references facebook_user_id:string
rails g model artist name:string
rails g model delivery user:references video_id:references date:datetime is_delivered:boolean

rails g controller accounts
rails g controller list index
rails g controller logout index
rails g controller policies privacy
rails g controller welcome index
