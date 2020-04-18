/* #version 450
#extension GL_ARB_separate_shader_objects : enable

layout(binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 proj;
    float time;
} ubo;

layout(location = 0) in vec2 inPos;
layout(location = 1) in vec2 inTexCoord;
//layout(location = 2) in vec3 inColor;

layout(location = 2) in float noteStart;
layout(location = 3) in float noteEnd;
layout(location = 4) in int noteKey;
layout(location = 5) in vec3 noteColor;

layout(location = 0) out vec3 fragColor;
layout(location = 1) out vec2 fragTexCoord;

const int N_NOTES = 48;

void main() {
    vec2 vtx_pos;
    float flotes = float(N_NOTES); //float notes
    // any other cases should be impossible
    switch (gl_VertexIndex) {
    case 0:
        vtx_pos.x = float(noteKey) / flotes;
        vtx_pos.y = noteStart - ubo.time;
        break;
    case 1:
        vtx_pos.x = (float(noteKey) / flotes) + (1 / flotes);
        vtx_pos.y = noteStart - ubo.time;
        break;
    case 2:
        vtx_pos.x = (float(noteKey) / flotes);
        vtx_pos.y = noteEnd - ubo.time;
        break;
    case 3:
        vtx_pos.x = float(noteKey) / flotes + (1 / flotes);
        vtx_pos.y = noteEnd - ubo.time;
        break;
    }
    gl_Position = ubo.proj * ubo.view * ubo.model * vec4(vtx_pos, 0.0, 1.0);
    fragColor = noteColor;
    fragTexCoord = inTexCoord;
} */

#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(binding = 0) uniform UniformBufferObject {
    mat4 model;
    mat4 view;
    mat4 proj;
    float time;
} ubo;

layout(location = 0) in vec2 inPos;
layout(location = 1) in vec2 inTexCoord;
//layout(location = 2) in vec3 inColor;

layout(location = 2) in float noteStart;
layout(location = 3) in float noteEnd;
layout(location = 4) in int noteKey;
layout(location = 5) in vec3 noteColor;

layout(location = 0) out vec3 fragColor;
layout(location = 1) out vec2 fragTexCoord;
layout(location = 2) out vec2 vNoteSize;

const int N_NOTES = 128;
const float blackWidth = 0.75;
const int nWhiteKeys = N_NOTES / 12 * 7 + (N_NOTES % 12);

bool isBlackKey(int x)
{
  x = x % 12;
  return x == 1 || x == 3 || x == 6 || x == 8 || x == 10;
}

int blackOffset(int x)
{
  int r = 0;
  x = x % 12;
  if(x > 1) { r++; }
  if(x > 3) { r++; }
  if(x > 6) { r++; }
  if(x > 8) { r++; }
  if(x > 10) { r++; }
  return r;
}

float getNoteOffset(int note)
{
  int octave = note / 12;

  int note2 = note % 12;
  note2 -= blackOffset(note2);
  float boff = isBlackKey(note) ? -blackWidth / 2.0 : 0.0;
  float x = (float(note2) + float(octave) * 7.0 + boff) / float(nWhiteKeys);

  return x;
}

void main() {
    if (noteStart == noteEnd) {
        gl_Position = vec4(0.0, 0.0, 0.0, 1.0);
        vNoteSize = vec2(0.0, 0.0);
        return;
    }
    vec2 vtx_pos;
    float flotes = float(N_NOTES); //float notes
    bool black = isBlackKey(noteKey);
    // any other cases should be impossible
    switch (gl_VertexIndex) {
    case 0:
        //vtx_pos.x = float(noteKey) / flotes;
        //vtx_pos.x = 1.0 / flotes;
        vtx_pos.y = noteStart - ubo.time;
        break;
    case 1:
        //vtx_pos.x = (float(noteKey) / flotes) + (1 / flotes);
        //vtx_pos.x = 0.0;
        vtx_pos.y = noteStart - ubo.time;
        break;
    case 2:
        //vtx_pos.x = (float(noteKey) / flotes);
        //vtx_pos.x = 1.0 / flotes;
        vtx_pos.y = noteEnd - ubo.time;
        break;
    case 3:
        //vtx_pos.x = float(noteKey) / flotes + (1 / flotes);
        //vtx_pos.x = 0.0;
        vtx_pos.y = noteEnd - ubo.time;
        break;
    }
    vtx_pos.x = inPos.x / float(nWhiteKeys);
    vtx_pos.x *= black ? blackWidth : 1.0; //make thinner if black
    vtx_pos.x += getNoteOffset(noteKey);
    gl_Position = ubo.proj * ubo.view * ubo.model * vec4(vtx_pos, 0.0, 1.0);
    fragColor = noteColor;
    fragTexCoord = inTexCoord;
    vNoteSize = vec2((black ? blackWidth : 1.0) / float(nWhiteKeys), noteEnd - noteStart);
}
