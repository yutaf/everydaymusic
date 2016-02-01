#!/usr/bin/env bash

rails g migration CreateJoinTableArtistUser artist user
rails g model user email:string locale:string timezone:integer delivery_time:time is_active:boolean
rails g model facebook user:references facebook_user_id:string
rails g model artist name:string
rails g model delivery user:references artist:references video_id:string title:string date:datetime is_delivered:boolean

rails g controller accounts
rails g controller list index
rails g controller logout index
rails g controller policies privacy
rails g controller unsubscribe index
rails g controller welcome index
rails g controller delivery show