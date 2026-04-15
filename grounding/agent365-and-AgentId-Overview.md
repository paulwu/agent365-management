---
Author: John Savill
Priority: 3
---

# Agent 365 and Agent ID Overview

**Source:** [YouTube — John Savill (March 2026)](https://www.youtube.com/watch?v=WTcyL68qTo8)
**Type:** Auto-generated transcript

---

Hi everyone. In this video, I want to provide an overview of agent 365. We hear a lot about it and many people are not clear on why we have it and what it is. So, I wanted to dive into that.

Now, we can really consider the idea today that the scale of the AI agent expected population is going to be enormous. Today we talk about, hey, there's millions of agents in the world.

By 2028, they expect there to be way more than a billion of these agents in the world. Microsoft alone is adding 5,000 agents a week. I think by April 2026, they'll have more agents than

employees. And maybe, while not as quick as Microsoft, nearly every customer is going to be following in that same journey. they're going to have this explosion of agents.

So if I consider the scale of all those agents and the increasing types of activities that will be performed by those agents for organizations, we actually have a huge challenge.

Uh don't know what agents they have which then limits the ability for them to be used effectively throughout the organization. If I don't know it's there, I don't know I can work with it.

I don't know my agent can go and talk to it. So there's a human and agent collaboration issue. It limits the ability for the organization to ensure the agent is maintaining its ability to

be fit for purpose that it's providing value. And I can't secure it. I can't protect it. I can't secure what I don't know about, what I can't see. How do I know these agents are operating with

lease privilege? How do I know they're operating within the guard rails? What data are they accessing? What are they maybe sharing? And in biology, you have this Maslo

hierarchy of needs. And I can apply that same kind of hierarchy when I think about agents.

So really the first thing I require is for my agent to have an identity.

It can't just always be working on behalf of the user. needs its own identity. Once it has its own identity, I can start thinking about applying security.

I can apply guard rails. I can then think about, well, is it staying fit for purpose? Is it actually being productive? So, it's useful.

And then I think about is it integrated into the enterprise? Can my employees and my other agents actually leverage it following their familiar types of workflow?

So I think about those as kind of some key requirements.

Let's forget about the idea of agents completely for a few minutes and instead let's just think about the idea of our employees, our friendly human employees and what

they need. Now at the most base level our employees they have an identity. So they have an identity in our intraenant.

So it used to be called Azure ID. So this is the digital representation for security, for collaboration, for other system access.

And what we then do is for that identity, well, we do a number of different things. I can think about well I grant it permissions. So we have the idea of role-based access control. I

give it roles. I give it access to resources. I give it access to SAS applications. I think least privilege.

It only gets what it absolutely needs. I may use capabilities like entitlement management which lets me grant access packages of access maybe time limited windows based

on the role they're doing to constrain that further on that identity. Well, I can do things like auditing.

I can track what they're doing logging on interactively, non-interactively, what systems they're accessing, all of those types of capabilities. And then I want to be able to control

what they do. I want to put conditions around maybe accessing more sensitive applications or more sensitive data. So we have things like conditional access in Entra that I use to control

how they're doing things. I can look at signals from the users's interactions, the times they log in, where they're logging in from, the types of actions they're performing, the devices, and I

can start to understand, well, are there any risk elements of the user overall or maybe a particular set of interactions, a particular session, I can even take those risk signals

and apply them as part of the controls I'm going to do. Hey, you seem riskier.

I'm going to limit what you can do. I'm going to make you go and perform some extra action. There's things like global secure access to help protect protected types of internet access secure services

edge. And then what I do is for all these identities, well, I put them in my global address list. Your address book you see in Exchange and Teams to know all about the different users you

have. So what that then lets me do is I can easily find other people. I could work out who I want to talk to. So it's a method of yes, I know the users I have, but it helps me discover other

users I may want to work with. So we use Entra. When I think about all of this identity side of things, it's entron is that solution for identity related protections, access visibility

and then I can think about well my employees they also interact with massive amounts of data.

Well, as an organization, I need to know where my data is. I have to discover it.

Then with that, I think about classifying it. I apply labels to it.

For example, based on the labels. So, I think information protection. I govern, I protect it. So, I then apply for example policy. I might even do AI based.

So, I can start to learn, hey, what's normal, what's outside it. I can then start to use data loss prevention to control how that data is being used.

So I have this very strong data protection and governance sets of capabilities I need.

Well, that's perview. So from a solutions perspective, my data I think about perview and it can also say hey look suddenly they're interacting with 500 documents

in 10 minutes. That's a bit odd. They're probably trying to do some kind of expiltration. There's an insider risk there. Let's restrict what they can do.

And then I think about threat protection. So obviously for our users, there are negative. There are these bad actors in the world that try and infiltrate devices, put malware, trick

our users, whatever that is. So I need threat protection.

And for threat protection, I think about defender many types of capability to help protect our users. And then of course to be productive,

what do they then do? Well, they go and interact with services. They go and interact with mailboxes. They have exchange. They go and access documents.

They have sharepoint. They have one drive for business. Hey, they collaborate on teams. They have meetings.

And so they obviously have those productivity capabilities. They use AI.

They use co-pilots. They have the AI meet them where they are in the existing experiences.

Well, our users, they leverage those as well. So they have these different capabilities they need to actually be productive to collaborate.

So that's the human. We address all these different requirements with these sets of solutions.

So now what about our agent? So my agent, this is not what your agent looks like, but we'll draw him it smiling.

So we have our AI agent. and think about the different types of agent we're going to have. They range in capability. I think today a lot about well I have assistants. So with an

assistant it's really working on behalf of me. I'm interacting with it. Turnbased interactions. It's access to things which largely be based around my

identity because we're interacting. It's working on my behalf.

But then I think about autonomous. With autonomous, it's triggered by an event. there's a a schedule, there's a mail arriving, there's some web hook, there's some series of things that

trigger it to then go and perform some task using generative AI to help it be successful to maybe work out a chain of thought so we can actually think through how do I solve this particular problem.

And it goes all the way through to the idea of AI teammates where we collaborate with it, we partner with it.

So if I think about that range of things that it's going to be doing, well then all of these same capabilities that we had for our employees, I need to apply to my agent as well. But

there's going to be some changes in certain details. So what I want to do and what agent 365 does is take all these existing ways of meeting the requirements but extends them to our AI

agents. I don't want a completely separate set of technologies, separate panes of glass, separate processes.

I want to take but modify so it's exactly fit for purpose and the behaviors of agents.

And that's what agent 365 is. So let's break this down and let's start with identity. Now you might look at identity and you say well okay let's just take what we had and commonly today

we think about we have identities for applications so a service principle but they're too limited. If I think about the types of tasks agents may want to do, especially when we get into this

sort of AI teammate type scenario, it's too limited. But also, applications tend to be very, very longived. Agents may be far more ephemeral. They're going to pop in and out of existence much

faster. So, you might say, well, let's use a regular user account. That doesn't really work either. A user is a physical being in the physical space. We have things like multiffactor authentication,

pass keys. I can't apply that to a an agent. An agent can't pop out its phone and click yes or say type in a number.

Maybe it could hire a human to go and do it if you look at some of these new services, but that's not practical. I would have to end up adding a whole bunch of exceptions

to not apply to my agents and that introduces other types of problem.

So really what we need to do is think about a different solution. I'm going to have lots and lots of probably instances of a specific agent in my organization. I want to be able to group

them together, work with them together. I need a hierarchy for the management and tracking. And so to solve this, if the human employee had sort of an entry identity, the user account, what we're

going to do for our agents is they're going to get an agent identity.

So my solution now will be an agent ID. So I'm going to try map it across neatly.

Agent ID. So every agent gets its own specific ident. Each instance of an agent. I might have 20 instances of the same agent. They each

will have their own identity. Now warning. Um, I'm going to go into some detail now. I remember there used to be a hair commercial. Uh, and it was this is the science bit. You may wonder why I

would reference a hair commercial. Whatever. Skip over that. If you're not interested in the details, just skip to the next bookmark. But I'll be quite quick, I promise. But I think it's super

useful to understand. Now, the way these agents work, remember the idea that, well, we're going to have multiple instances. We want to be able to group them and have a hierarchy and

not keep reinventing the wheel. What we actually start with is if we think about my tenant. So if I think of a publishing tenant now that's your entra tenant. And the

reason I'm writing publishing tenant is if it's just for you and your organization you're creating this that's just your tenant. But if you're an ISV, if you're creating agents that you want

other organizations to use, you probably have a publishing tenant where you today publish software from that's part of the Microsoft partner program. And you would use the same thing here for your agent

creation because you're going to want the little check mark next to your agent because like apps, agents can be multi-tenant. So any organization in the world could choose to deploy your agent

into it or it can be single tenant. Hey, I just want it in my particular tenant.

Again, just like app registrations. So again, if this agent is just for you, that's just going to be your tenant.

Don't worry about it. Now, what we're going to do is we create something called a blueprint.

I guess really I should have changed the color of my pen.

We have a blueprint. This is a template for the agent identity. So, think of this as a template.

Now, it's going to have things like a description of what it is, but it's also then going to have roles. So, as part of this template, I define various roles.

And remember, the agent, it could be doing things on its own. So, it's going to have its own sense of like app level permissions, API permissions, access to Azure resources, maybe it's mail read,

but also there's going to be permissions that I would consent to so it can work on my behalf. So, there's going to be times I want an agent, especially in this kind of assistant mode, it wants to

be able to act as me and get a delegated token as me to go and do things that I want it to do. So these roles here ultimately what will happen is they will get inherited through the agent

identities I'm going to ultimately create. Now I don't have to do this here.

I can also when I create the agent ids add additional permissions.

Um and so you don't have to do this bit but if there was a set of permissions you always want your agents to have hey I set them in the blueprint. There are

some permissions I cannot give agents. Um, if I think about user readrite.all, you cannot give that to an agent. I do not want an agent to maybe go off the rails and decide to remove all user

accounts. That that would be not good. So there are certain permissions in it document that you cannot give to an agent. The other thing that happens at the blueprint and this is really

important is the authentication part. So how it's proving it's allowed to act the authentication I set on the blueprint. Now ideally this is going to be some kind of federation.

So if this was running on the Microsoft agent platform, this was co-ilot studio agent builder foundry the built-in co-pilot and Azure resource. It's basically like a managed identity. It's

just native to the platform. There's other types of federation you can do as well. I could use a certificate.

Technically, I could use a secret, but I'm going to put a huge kind of frowny face. You you shouldn't be doing that. I I don't want to use a secret for these types of things. So, this is an

important point to take away. It is the blueprint that authenticates.

These agent identities we're going to end up creating do not have their own credentials. the foundation, the platform that runs the agents

will be the ones that actually are doing the authentication via the blueprint.

What we then do is because remember this could be multi-tenant. So actually move this up a little bit, give myself a bit more space.

Remember I can be multi-tenant here. And so the next thing I need to do is consider well I have to consent that I want to use the blueprint in my tenant.

So I perform a consent action and when I consent within my tenant that I consent in I get a blueprint service principle. So this is when I do this consent process

it goes ahead and does this. Now, if this was a multi-tenant blueprint, a multi-tenant agent, if there was another tenant, so let's say someone else, so

some other tenant that wanted to use my agent, there's only ever one copy of the blueprint that exists in the people that create it, but they would consent in their tenant as

well. And when they did the consent, they would get their own blueprint service principle that is linking from the blueprint in the publishing

tenant. And again, this is going to seem super familiar to developers used to app registrations and then the enterprise app which is just a service principle.

It's following exactly the same pattern. So just realize and then that would go and create agent identities in its tenant.

back to here. So now I've consented there's a manifestation of the blueprint in my particular tenant and it has a birthright permission to create Asian identities. And so this is now the big

exciting thing. Hey, we're going to go down and actually create our agent ID. Now remember it can inherit these app permissions on itself

and also things on behalf of the users will consent to. I can add additional ones. So as part of this experience I could add additional app permissions. I can add additional on behalf of specific

to this agent. So this particular agent ID yes will inherit these but also it can have additional ones because maybe the exact purpose it's doing that there's something else and

another permission it needs. So now I create multiple agent IDs from the blueprint.

As part of this creation though, there's something else I have to have cuz remember some of the pain points we have agents sprawl. They become orphaned. I don't know what they're being used for.

I don't know who owns it. Do I need to keep the thing around? So when I do this creation, every single agent ID must have a sponsor.

So this is the person responsible. They have accountability for the agent. They decide is this agent is still needed or not. So you won't end up with these orphaned agents. Now

optionally I can add owners. That would be from a technology perspective. They have permissions to do things on the agent. I can add managers for them. But they have to have a sponsor so they

don't just have this spraw and I don't understand are they still did what they are and then the whole goal here is this agent ID is just utilized by specific

instances of the agent. It's just now leveraged. Now I did a whole bunch of talking a whole bunch of blueprint and blueprint service principles and agent identities.

This is just done for you. If I'm using a platform like agent builder, co-pilot studio, Microsoft foundry, security code, and it's going to grow, they're just done. For example, if I'm using

Microsoft Foundry, my project has its own blueprint. It has agent identities.

When I publish an agent, then that gets its own blueprint and then that becomes the parent for any instantiated agents.

Other agent platforms will probably be updated to do this as well, but I can do it myself. I can use the uh Microsoft authentication libraries. I can use the entra powershell modules. I can use the

graph API to go and create all of these things and use if I am rolling my own agent platform.

Now one important thing this agent ID is really like a service principle behind the scenes at this point. So it's fine for many many different scenarios.

But what it can't do is talk to things like exchange. It can't have an Exchange mailbox. It can't participate in teams.

It can't go and be given access to SharePoint. If our agent needs those types of capabilities, we have to extend it. And the way we extend it is we create

an agent user. This is still an entra. It's still using all the same APIs, but now I get this entry user as a child of the

agent ID. So they are related to each other. So this is also going to actually be created by this blueprint service principle. It actually goes, if I'm doing my little lines correctly, it

would now go and create that particular agent user as well. And the key point then is this agent user can go and access those types of experiences.

So it could now have a mailbox. It could participate in Teams. It could work in SharePoint. I could be in a Word document and app mention it. Or in Teams I can send it an email. I can ping it on

Teams. employees can just interact in very natural ways they're used to in their workflows in working with colleagues. Now again, this is completely optional, but it's when I

want to extend the reach of my agent and collaborate naturally.

So without this, okay, let's take a step back. Without this, if I wanted to get my agents attention and get it to do something, let's say I'm working in a Word doc, I would have to cut and paste

a section of the Word doc, put it in a chat experience, reference the document, describe what I want it to do. Hey, please rewrite these things. It's a lot of typing. It's a lot of figuring out

what's doing the prompt compared to I would just go into the dock, highlight it, add a comment. Hey, agent, go do this.

I'm done. I'm not describing the dock. I'm not describing the paragraph. The context is all there. So, it's just super easy for me to go and work and interact with it. Now, a key point is

when I start thinking about agent users working with Exchange and SharePoint and Teams and the Microsoft that semantic index that that work IQ capability to get the entire context and knowledge of

the enterprise. When I'm doing those things, I think work IQ.

This is where I need that agent 365 license.

So that's a key. When I want my agent to start interacting with those services, I need agent 365. That's the like a user. Remember, I license for M365 to use those experiences. my agent I will

license for A365 to use those experience and going to see these same capabilities here as well. So that's the key point.

One more techy bit if you're interested how does this actually get used then all of these identities if the credential is up here. So all that happens is my agent platform wants to run the agent and get

a token so the agent can do its thing. the agent platform. So, Foundry, so co-pilot studio, remember it has the managed identity to just be able to authenticate as the blueprint. It

created the blueprint. It has the ability to act and get tokens as the blueprint. So, what will actually happen here from an authentication perspective is

that agent platform authenticates with this service principle. Now, as part of that authentication, it gets a special type of token that it's going to use to exchange. So, it's

going to get a token to exchange. It takes that token to exchange and exchanges it for a regular token for a specific agent ID. So, this one here.

So, I would exchange it for a token for that identity. So, now I have a token as that agent identity. the agent can use that identity to go and get all of the different access and resources it has

been given access to. So this is basically using a federated identity flow.

If I want to be able to use the user, well I just do the same thing. I take my token to exchange and this token. So I use them together to get a token as the agent user and I

can go and use it in its experiences. So that's how those things work together.

That was a whole lot of identity. Again, the Microsoft agent platforms just take care of all of this. I'm sure the other third parties will do that as well. But the whole goal here is

this is not Microsoft specific. any agent on any platform can just use the graph APIs again the entra powershell the micros authentication library to create the blueprints to consent to get

the service principle to create the agent ids to use with their agents and get that identity and get all of the fantastic stuff that we're actually going to go through but now if we think

about it what remember our problems we had we have an identity I can tick that off that's done every agent has its own identity so we can start to build on that and that's the key goal.

So let's actually just quickly go and and look at that aspect for a second. So if I jump over so here I'm using the Microsoft Zava just it's got a lot of interesting

agents. We can see I've got a certain number of agents but also what's most interesting here it's not just Microsoft. Yes, there's a whole bunch of Microsoft Copilot Studio

and Foundry, but there are ones from other platforms as well. So, all of those can go in and actually have agent identities. And we can see here there are obviously agents created by my

organization, but there are also ones from those kind of external partners. So we have this very rich ecosystem.

But now all of the agents, not just Microsoft, they can have identities.

And now I have that identity. I can now take all of those same capabilities that we had for our employees and start applying them to our agents. So obviously I can do things like hey I

think about those role based access controls.

So for this agent ID yes I have arbback I can assign it certain roles as we saw certain API permissions access to Azure resource it has things that can do on behalf of I can use entitlement

management. I can actually go ahead and grant it as the owner for example give it access to certain packages.

I can target it with conditional access. So I have a lot of rich capabilities specific to actually conditional access.

If I jump over for a second actually I'm just going to go to regular conditional access.

So conditional access I can assign to different types of resource the requirements I have oh I have the ability to target my agents

and then within the agents I could do all agents or select agents and for select agents I can say well if it's working on behalf of a user if it's based on certain attributes or even just

select specific individual agent identities and then it will show me.

I've got a whole bunch of Foundry blueprints here. Remember, we get one for each Foundry project by default. So, I can just go and target specific agents or specific types of agent behavior as

part of this. So, I'm taking my existing skills, my existing capabilities and assign it to my agents.

I can do things like risk detection. I can understand risk in terms of there's risky users using the agent, but I can also look at the agent behavior, but it understands the difference. If I

saw a human working 24 hours a day, that's a bit odd. They're probably sharing their account. I would trigger warnings. If I see an agent working 24 hours a day, that's expected. And once

again that risk flows in as one of the conditions I can have to decide hey is is that okay or should I maybe block the access conditional access is how I allow the agent and those

identities to use resources the conditions around that and once again if we jump over to the zava let's have a quick look at this I can actually think about here

it it's showing Hey, look if there's certain kind of agent risks here. But if I actually just look at let's manage these for a second and we'll look at the Zava store. It has its permissions.

So it has permissions that it has. Then it has permissions that it can work on behalf of the particular user where they consent.

I can look at the activity of the agent, how it's actually being used, who is using it. If I look at my security and compliance, I've got signals here from Entra. So, hey, look,

it was used by a risky user. There's been some abnormal signin frequency. So, it is doing something outside of how it normally behaves. But the whole point of this is it's kind of telling me hey look

it has its own specific identity and it is being governed by all of those entry protections. There's even things like the global secure access and the secure service edge where some of the platforms

there I think copilot studio hey if I'm accessing other types of internet resource it will go and look at those as well and so also hey I am getting that audit you kind of saw that information

so it's auditing what it's doing in my environment and very commonly when I start to think about everything the agent is doing. I'm going to combine this. So, auditing the

authentications of the identity, the data access, that's definitely part of the story. But remember, my agent is running on a certain agent platform. And very commonly, I'm going to think about

maybe it's Microsoft Foundry, maybe it's Co-Pilot Studio, Agent Builder, you kind of name it. Remember they have entire control planes like Foundry has a fantastic control plane

for observability for content safety. So the prompts, the attachments, the logic, is it hallucinating? Is there jailbreak attempts? Is it prompt injection? Are there reasoning failures? Evaluations to

make sure there's no regression in its capabilities. It staying fit for purpose. And one of the nice things about this is again if it's not a Microsoft platform using some other

agent platform well it has the AI gateway which is actually built on API management and so my third party agent platforms

can use the AI gateway to use the features of Foundry to add to that visibility that observability that full scope of knowledge and is it fit for purpose, the guard rails, the

protections I want. So I combined the agent platform capabilities and that the content safety again doesn't have to all be Microsoft either with the signals from the agent identity. So again, if I

look at my list, so suddenly now what am I doing? Well, I'm starting to approach things like, hey, the fit for purpose.

Should have done green for that. Hold on.

It's fit for purpose. I'm putting the guard rails. I'm starting to address the security aspects of it. I'm checking is it productive through these types of um interactions and capability. But

obviously that's that's not the whole story because then we have things like all the data access and once again as the agent interacts

with various types of data her view is looking at it as supposed to be a magnifying glass. So as the agent is working with data

view is going to be inspecting how it's doing that. And again, remember agents behave very differently from users.

Perview has been adapted to understand the behavior of agents. If the user is looking at 500 documents in 5 minutes, they're exfiltrating data to do something bad. If an agent is scanning a

thousand documents in 3 minutes, it's just retrieve log manage generation.

That's normal. It's doing its job. And so her view is going to adapt to actually look at how those interactions are happening. And once again, if we jump over to that board, we saw this.

So here I can see how perview is kicking in.

It's monitoring the data activities. It's prevented activities. It's not just looking.

It's saying, okay, you've tried to access data that's labeled and maybe it's sensitive. Maybe it's not to be used for grounding in AI. whatever that is,

it's looking and protecting the AI interactions in the same way it looks and protects employee interactions. And then you also see, as we're going to come on to in a second, defender is

protecting this agent as well. And so what we've got now is perview is looking at the AI interactions. It's comparing it against policies and it's blocking where it needs to. And then

yes, finally, defender. It's helping protect. If we think about AI security posture management, it's going to help discover, identify agent vulnerabilities, misconfigurations,

excessive permissions. There's an AI runtime protection for agents. So what that is doing is it's going to in real time detect and block malicious uh unintended agent actions across even

different environments, platforms, devices is using some of the agent observability logs, web hooks to really go and detect and give me that idea of threat protection. So what I get now is

defender I get AI specific threat protection.

through all of these different interactions block malicious activity in the agents including those direct and indirect jailbreaks fishing attacks um ASI smuggling suspicious access from

tour malicious IPs unsafe to invocations um I'm trying to break the intent whatever that may be it's going to help me so therefore with that real time blocking There's

also going to help me with hunting with those investigations.

So if there is a threat, I'm going to understand the full incident context and I would see, hey, look, maybe there was some user got some weird there's there's a whole attack chain. I would

see the full attack chain. I could see the agent security events, the trace agent behavior, the talk calls, the MCP interactions, the planning steps, the multi- aent communications, all of that

will be surfaced to me. So, I'm getting all of the same types of capabilities I want for my employees, but they're being tailored to what is relevant to the agent, the types of

interaction the agent has both itself and on behalf of. I'm understanding the way agents will work with data. I'm understanding the unique types of threat agents will expose and I'm enabling it

to go and have these experiences, the Microsoft 365 sets of experiences, the work IQ which has that full work context. It learns the relationships between uh the data between the people.

It gets a memory. There's specific inferencing types. all the stuff I do as a human when I look at messages and documents and meetings and transcripts and I build up that mental graph of

relationships and how they relate to each other. I learn and be proactive.

Work IQ does that and provides that for your agents. Uh and then I get Power Apps. I get PowerBI usage. And so this is what agent 365 is like because it's that summary element. It's this it's all

of these capabilities for your agents.

But there's another aspect and you kind of saw it for a second when I was in the other console.

We have a registry. So if I think about this idea that okay, I've got these agent ids.

The other fantastic capability we get right here is this idea of a registry.

And so all of my agents are going to be part of this registry.

So what does that do? That gives us actually multiple aspects. Yes, I get inventory.

So I know what agents I have. So I can understand my agent estate. But the other thing I can actually do here is I can have agent cards. Think of manifest for the agent. So the agent abilities,

its skills, how it can interact with other agents.

So then other agents can discover what agents exist and then interact with them. Think things like A to A. So agents will use the registry to discover other agents. And the key word is

discovery. This is not access control of this agent can use this agent. That would be things like the roles and conditional access. This is about their ability to find each other. Hey, I use

the gal. The gal doesn't control who I can speak to, but the gal helps me find people. The registry helps me find or the agents find other agents. It helps me as a human see the agents that are

out there. Any agent can be in the registry.

Only agents with an agent ID can query and discover from the registry. So I don't have to have an agent ID to show up in the registry. So I absolutely could go ahead and have

You can't even see that, can you? That's useless.

I absolutely could have other agents. So this is other and I can add them to the registry. They do not have to have an agent ID. But remember, even these other agents can

have agent IDs because I can use MEL graph, you name it to give any agent on any platform an agent identity to then use A65 to get all of these capabilities for my agent. But if it

doesn't have that, I can still add it to the registry. So then I can inventory it as of my organization. So other agents can go and discover it. So those are really great capabilities between there.

And then what it does is that registry will then let me understand some of the interactions between them. So if I jump back over again for a second, I can go and look

sure at all my agents. This is just a registry.

And let's just jump back up a second. So I see all my different agents. I' got agents around here. Just look at all of them.

The other thing I can do is I can do a map.

So this is grouping it right now as part of the platform.

So I could see, okay, the ones in Foundry and Copilot Studio, Microsoft and Google and Bedrock. I can kind of see other agents they're talking to but also then I could open up and go and

get the details around it. So it makes it really easy to understand the agents in my environment. I could even look at requests for agents that are kind of pending that I need to

validate. But the other thing I can do here so these are like very large scale the registry are all my different agents.

But one thing I might want to do is have maybe a smaller subset of discovery. So one of the things I can do is I can create collections. These are completely optional

and there are systemwide collections that are just built in. And then there's also collections I can go and create. So over here for a second, if I go and look at my agents and collections,

there's two predefined global So everything can kind of see everything. Quarantined. These are agents that no one will be able to see.

So if I have an agent and there's been a problem with it, I've got some risk, I can put it in quarantine and then no one will be able to discover it.

I can also create custom collections. So maybe there's a particular group of agents, maybe they're around a certain business function. Maybe it's salesreated or it's a particular

business unit, whatever that might be. I can create specific collections to help those agents just find agents specific to that purpose. But they're still about discoverability. They are

not controlling access. If I want to control access, that's still things like enter groups. I can put agents into groups to control access, conditional access. This is about discovering. So

you can kind of think of it a lot like the idea of, hey, the gal we have for the humans. It's a way for agents to go and find each other.

And so this is honestly how I think about agent 365.

It is bringing all of the abilities together that we consider critical.

So now again we have that integration is my final tick because that collaboration with the different experiences with the shareepoint with the teams with the

email with the hatment mentioning in whatever I'm doing I'm addressing all of those various needs through A365.

So yes I've got my entra so I have my identity and apply all those types of protections on it. I'm looking at how it's interacting with data. I'm doing the AI specific types of protections.

I'm giving it all of the productivity. And of course, this is A365. I then could also go and use the rest of Microsoft IQ, the fabric IQ, the foundry IQ to see the state of my business to

get very curated that enterprise knowledge that I want to get access to as well. So all of those come into play as well. But every agent has its own unique identity. They have a sponsor. So

I know who is accountable. I have purview for the data governance, the protection, defender for threat protection. I have this great registry so I can then easily inventory so agents

can discover each other. And that was it. Um, I hope that was useful. I hope it gives you an idea of what A365, agent 365 is. Till next video, take care.

A big