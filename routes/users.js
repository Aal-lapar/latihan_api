const express = require('express')
const routers = express.Router()
routers.get('/get',(req,res)=>{
    res.send('succes route get!')
})
routers.post('/post',(req,res)=>{
    res.send('succes route post!')
})
routers.put('/put',(req,res)=>{
    res.send('succes route put!')
})
routers.patch('/patch',(req,res)=>{
    res.send('succes route patch!')
})
routers.delete('/delete',(req,res)=>{
    res.send('succes route delete!')
})

module.exports = routers;